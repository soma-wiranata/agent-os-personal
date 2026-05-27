---
source: hono
category: auth
---
# Auth Context Injection

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
