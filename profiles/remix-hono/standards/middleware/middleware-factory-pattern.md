---
source: remix
category: middleware
---
# Middleware Factory Pattern — `[middleware, getter]` Tuples

All middleware uses a factory function that returns a `[middleware, getter]` tuple.
- All middleware files MUST be named `*.server.ts` and placed in `~/middleware/`
- Never import middleware factories from `remix-utils` directly in route files — always re-export from your `~/middleware/*.server.ts`
- Add middleware to `export const middleware: Route.MiddlewareFunction[]` — in `root.tsx` for global, in a layout route for scoped

```ts
export const [sessionMiddleware, getSession] = createSessionMiddleware(sessionStorage)
// root.tsx
export const middleware: Route.MiddlewareFunction[] = [sessionMiddleware]
// loader
let session = getSession(context)
```
