---
source: hono
category: auth
---
# Non-Blocking Session Middleware

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
