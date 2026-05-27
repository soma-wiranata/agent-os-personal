---
source: hono
category: auth
---
# Per-Request Auth Factory

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
