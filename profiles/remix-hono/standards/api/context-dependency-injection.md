---
source: hono
category: api
---
# Context Dependency Injection

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
