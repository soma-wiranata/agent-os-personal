---
source: hono
category: api
---
# App & Route Registration

Collect all routers into a typed `as const` array in `app.ts` and mount them via `app.route('/')`.

```typescript
// app.ts
const routes = [index, auth, tasks] as const
routes.forEach((route) => app.route('/', route))
export type AppType = typeof routes[number]   // for hono/client RPC
```

- Every new router must be added to this array — otherwise it won't be served and its types won't be exposed to clients
- Never call `app.route()` outside of `app.ts`
