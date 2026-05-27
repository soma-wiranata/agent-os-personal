---
source: hono
category: auth
---
# Auth CORS — Scoped to `/api/auth/*` Only

Apply CORS middleware only to Better Auth routes — never globally.

```typescript
app.use('/api/auth/*', authCors)   // ✓ scoped
app.use('*', authCors)             // ✗ never global
```

- `credentials: true` is required for Better Auth's cookie-based session flow
- Applying `credentials: true` CORS globally exposes it to all endpoints — a security risk
- For non-auth routes that need CORS, define a separate cors middleware with appropriate restricted settings
