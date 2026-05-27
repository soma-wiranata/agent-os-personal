# Auth Standards

## Rules

---

### Per-Request Auth Factory

Never instantiate `betterAuth` at module level. Create a new instance per request via `createAuth(env)`.

```typescript
// lib/auth.ts
export const createAuth = (env: Environment) => {
  const db = createDb(env)
  return betterAuth({
    database: drizzleAdapter(db, { provider: 'pg' }),
    socialProviders: { google: { clientId: env.GOOGLE_CLIENT_ID, clientSecret: env.GOOGLE_CLIENT_SECRET } },
  })
}

// Usage in middleware/routes
const auth = createAuth(c.env)
return auth.handler(c.req.raw)
```

- Edge/serverless runtimes have no persistent module scope — env vars arrive per-request via `c.env`
- A module-level singleton captures stale or missing env at cold-start
- Always pass `c.env` (the typed `Environment`) — never `process.env` directly

---

### Non-Blocking Session Middleware

The global session middleware must never return 401/403. It only populates or nulls context variables.

```typescript
const withSession: MiddlewareHandler<AppBindings> = async (c, next) => {
  const auth = createAuth(c.env)
  const session = await auth.api.getSession({ headers: c.req.raw.headers })
  c.set('user', session?.user ?? null)
  c.set('session', session?.session ?? null)
  return next()   // ← always continues, never rejects
}
```

- Separates session resolution (infrastructure) from authorization (business logic)
- Routes that require auth check `c.var.user !== null` themselves or delegate to a guard middleware
- Always read session from `c.var.user` / `c.var.session` — never call `auth.api.getSession()` again inside a handler

---

### Auth CORS — Scoped to `/api/auth/*` Only

Apply CORS middleware only to Better Auth routes — never globally.

```typescript
app.use('/api/auth/*', authCors)   // ✓ scoped
app.use('*', authCors)             // ✗ never global
```

- `credentials: true` is required for Better Auth's cookie-based session flow
- Applying `credentials: true` CORS globally exposes it to all endpoints — a security risk
- For non-auth routes that need CORS, define a separate cors middleware with appropriate restricted settings

---

### Auth Context Injection

Inject the verified user payload into Hono's context via a dedicated auth middleware.

```typescript
// auth-middleware.ts
c.set('user', jwt.payload)

// types.ts
interface Env {
  Variables: { db: DB; user: EnvUser | null }
}
```

- The user payload type (`EnvUser`) must be strictly typed in the central `Variables` type
- Ensure auth middleware runs before route handlers — user context must be guaranteed available (or `null`)
- Always use `AuthUtils.getUserId(c)` helper methods instead of `c.get('userSession')` directly where available

---

### Cross-Subdomain Authentication

Configure `better-auth` for cross-subdomain cookie sharing when running multi-service monorepos.

```typescript
{
  advanced: {
    crossSubDomainCookies: { enabled: true, domain: '.yourdomain.com' },
  },
  trustedOrigins: ['https://yourdomain.com', 'https://api.yourdomain.com'],
}
```

- Allows users to log in once and be authenticated across all subdomains automatically
- Disable in local development when running on `localhost` without proper subdomains

---

### Session Database Hooks

Use `databaseHooks` to automatically inject additional metadata into session objects at creation time.

```typescript
databaseHooks: {
  session: {
    create: {
      before: async (session) => ({
        data: { ...session, activeOrganizationId: await getActiveOrg(session.userId) },
      }),
    },
  },
}
```

- Ensures custom session data (e.g., `activeOrganizationId`) is populated at the DB level without extra client round-trips
- Prefer hooks over adding a middleware that re-queries session data on every request

---

### Cloudflare Workers Auth Setup

When configuring `better-auth` for Cloudflare Workers, wrap configuration using `withCloudflare`.

```typescript
const auth = betterAuth(withCloudflare({
  autoDetectIpAddress: true,
  d1: { db: dbInstance },
  kv: env.KV,
}, { /* other better-auth configs */ }))
```

- Cloudflare D1/Hyperdrive and KV bindings work differently than Node.js — the wrapper safely integrates them into `better-auth`'s adapter

---

### Double Cookie Strategy

Use a double-cookie pattern for auth tokens and abstract cookie operations behind `tokenActions`.

```typescript
export const tokenActions = {
  saveToCookie(token: string, c: Context) {
    setCookie(c, 'access-token', token, { httpOnly: true, secure: true })
  },
  saveUserToCookie(user: EnvUser, c: Context) {
    setCookie(c, 'user-data', encodeURI(JSON.stringify(user)), { httpOnly: false, secure: true })
  },
}
```

- `access-token`: always `httpOnly: true` (server-only security)
- `user-data`: `httpOnly: false` so the frontend can read the payload synchronously without an extra `/me` fetch
- Never call `getCookie`, `setCookie`, or `hono/jwt` directly inside route handlers — always route through `tokenActions`
