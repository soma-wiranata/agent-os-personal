# API Standards

## Rules

---

### Context Helpers

Always use Hono's built-in `c` (Context) helpers for constructing responses instead of returning raw `Response` objects.

- Use `c.json()` for API endpoints, `c.text()` for plain text/webhooks, `c.html()` for HTML
- Use `c.notFound()` and `c.redirect()` for their respective behaviors
- Never return `new Response(JSON.stringify(...), { headers: {...} })` in any handler

---

### Typed App Instantiation

Always instantiate Hono apps and sub-routers with explicit `Bindings` and `Variables` generic types. Never use a raw `new Hono()`.

```typescript
// Define once in types.ts
const app = new Hono<{ Bindings: Bindings; Variables: Variables }>()

// For sub-routers, always use createRouter() (never new Hono() directly)
import { createRouter } from '@/lib/create-app'
const router = createRouter()
```

- Maintain a central `types.ts` exporting `Bindings` (env vars, KV, D1) and `Variables` (request-scoped context like `user`, `db`, `session`)
- Prevents `c.env.MISSING_VAR` runtime failures through TypeScript enforcement

---

### Context Dependency Injection

Inject database clients and external services via middleware into `c.var` — never import them as module-level globals.

```typescript
export const dbMiddleware = createMiddleware<HonoEnv>(async (c, next) => {
  c.set('db', getDbInstance(c.env.DATABASE_URL))
  await next()
})

// In handler
const db = c.var.db
```

- In serverless (Cloudflare Workers), env vars are bound per-request via `c.env` — singletons capture stale state
- Simplifies testing: mock via context injection, not module mocking
- **Exception:** Pure utility functions with no env dependencies may be imported directly

---

### OpenAPI Route Definitions

Define all public API routes using `@hono/zod-openapi`'s `createRoute()` — not standard `app.get()`.

```typescript
const getRoute = createRoute({
  method: 'get',
  path: '/{id}',
  request: { params: ParamsSchema },
  responses: {
    200: { content: { 'application/json': { schema: MonitorSchema } }, description: 'The monitor' },
    ...openApiErrorResponses,
  },
})
```

- Provides runtime request/response validation and auto-generates Swagger/Scalar documentation
- Use `defaultHook: handleZodError` on routers for standardized validation failure responses
- Internal routes (webhooks, cron handlers) may use standard Hono routing — `createRoute` preferred for consistency

---

### Route File Structure

Separate OpenAPI route definitions from business logic handlers across three files per resource.

| File | Purpose |
|---|---|
| `*.routes.ts` | OpenAPI route definition, request/response schemas, tags |
| `*.handlers.ts` | Business logic, uses `AppRouteHandler<T>` type |
| `*.index.ts` | Binds routes to handlers via `createRouter().openapi()` |

- **Exception:** Single simple endpoints may be grouped into one file if three files is overkill
- Route handlers must use `AppRouteHandler<RouteType>` — never untyped async functions

---

### Standardized HTTP Status Codes

Always use `stoker/http-status-codes` for status codes — never raw integer literals.

```typescript
import * as HttpStatusCodes from 'stoker/http-status-codes'
return c.json(data, HttpStatusCodes.OK)   // ✓
return c.json(data, 200)                   // ✗
```

- Prevents magic numbers and eliminates typos in status codes

---

### Global Error & 404 Handlers

Register `app.notFound()` and `app.onError()` once in `createApp()` before any routes.

```typescript
import { notFound, onError } from 'stoker/middlewares'
app.notFound(notFound)
app.onError(onError)
```

- Use `stoker/middlewares` defaults unless you have specific custom logging requirements
- Never handle generic errors inside individual route handlers via `try/catch`

---

### API Response Envelope

All public-facing API responses must follow a consistent `success / error` envelope.

```json
// Success
{ "success": true, "message": "...", "data": {} }

// Error
{ "success": false, "error": "NOT_FOUND", "message": "...", "details": {} }
```

- Clients always check `success` first before parsing the payload
- Error codes must be uppercase strings (e.g. `INTERNAL_ERROR`, `VALIDATION_ERROR`, `NOT_FOUND`)
- Use a `result.success()` / `result.error()` utility wrapper — never return raw JSON objects

---

### Custom Error Throwing

Throw structured custom errors from business logic — never return `c.json({ error })` manually inside handlers.

```typescript
import { CommonErrors } from '@/middleware'
if (!user) throw CommonErrors.notFound('User')
if (!hasAccess) throw CommonErrors.forbidden('Requires admin access')
```

- Custom error classes carry a `statusCode`, `code` string, and optional `details`, mapping cleanly to the response envelope
- The universal `app.onError()` handler formats and sanitizes these automatically
- In development: includes full stack traces. In production: strips internals, shows generic messages

---

### Empty PATCH Validation

Manually validate that PATCH request bodies are not empty objects before processing.

```typescript
const updates = c.req.valid('json')
if (Object.keys(updates).length === 0) {
  return c.json({ success: false, error: { issues: [{ code: ZOD_ERROR_CODES.INVALID_UPDATES, ... }], name: 'ZodError' } }, HttpStatusCodes.UNPROCESSABLE_ENTITY)
}
```

- Zod allows empty objects for partial schemas — this check must be manual
- Always use `ZOD_ERROR_CODES` / `ZOD_ERROR_MESSAGES` constants for consistency across PATCH routes

---

### Idempotent Database Inserts

Use database-level upserts (`onConflictDoUpdate` / `onConflictDoNothing`) for webhook and polling ingestion routes.

```typescript
await db.insert(repositories).values({ id, name }).onConflictDoUpdate({
  target: repositories.id,
  set: { name },
})
```

- Webhook delivery is "at least once" — the same event may arrive multiple times
- Never use "check then insert" — it races; handle conflicts at the DB level
- Always declare an explicit `target` constraint column and `set` fields to update

---

### Asynchronous Background Processing

Never pass the Hono request context `c` into fire-and-forget background execution chains.

```typescript
app.get('/checker/:period', async (c) => {
  const period = c.req.param('period')   // ✓ extract primitives first
  void runInBackground(period)           // ✓ no `c` captured
  return c.json({ success: period }, 200)
})
```

- Extract all path params, queries, and headers into local primitive variables before launching background work
- Use a global/background error reporter (not request-scoped telemetry) inside background chains
- Return the HTTP response immediately after launching — never `await` background work

---

### Tenant Scoping

All multi-tenant API endpoints must enforce workspace isolation and filter soft-deleted records.

```typescript
const workspaceId = c.get('workspace').id
const record = await db.select().from(monitor).where(
  and(eq(monitor.workspaceId, workspaceId), isNull(monitor.deletedAt))
)
```

- Always fetch tenant ID from context (`c.get('workspace').id`) — never from request body
- Always filter with `isNull(table.deletedAt)` for active-record queries

---

### Internal Route Protection

Protect internal cron/webhook endpoints with Basic Token auth against a shared secret.

```typescript
const auth = c.req.header('Authorization')
if (auth !== `Basic ${env().CRON_SECRET}`) return c.text('Unauthorized', 401)
```

- Internal routes don't need OpenAPI docs — use standard `Hono` (not `OpenAPIHono`) and validate payloads with `schema.safeParse()`
- Return `422 Unprocessable Entity` on failed validation, `401 Unauthorized` on auth failures

---

### App & Route Registration

Collect all routers into a typed `as const` array in `app.ts` and mount them via `app.route('/')`.

```typescript
// app.ts
const routes = [index, auth, tasks] as const
routes.forEach((route) => app.route('/', route))
export type AppType = typeof routes[number]   // for hono/client RPC
```

- Every new router must be added to this array — otherwise it won't be served and its types won't be exposed to clients
- Never call `app.route()` outside of `app.ts`

---

### Export Pattern

The main app entry always exports the default `app` instance.

```typescript
export default app
```

- Required for Cloudflare Workers, Bun, and `serve` deployments
- Never mix named exports for the primary app instance unless a specific adapter requires it

---

## Flagged (Score 2 — Review Needed)

- **Text-based Error Returns for Webhooks**: Returning `c.text(error, 500)` for webhook/internal endpoints is pragmatic (webhook providers only check HTTP status), but conflicts with the general response envelope. Decide: carve out webhooks explicitly as an exception, or wrap in envelope regardless.
- **Class-Based Controllers** (hono-telescope): Organizing handlers as methods on a Controller class is useful for DI but is not adopted across other repos. Consider standardizing if services grow complex.
- **Dynamic Asset Serving** (hono-telescope): Serving assets via `c.body(content)` with manual `Content-Type` headers applies only to embeddable library middleware packages — not general app use. Only apply this pattern when building drop-in middleware.
