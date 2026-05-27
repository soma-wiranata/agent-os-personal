---
source: remix
category: security
---
# CSRF — Header-Based Middleware (Preferred for New Projects)

Use `createCsrfMiddleware` for modern CSRF protection based on `Sec-Fetch-Site`. No tokens needed.
- `same-origin` / `same-site` → always allowed; `cross-site` → blocked by default
- If the app has API/webhook routes that must accept cross-site requests, scope the middleware to a UI layout route, not `root.tsx`
- Never use `allowMissingOrigin: true` unless all clients are verified
- Never use a global-flagged `RegExp` in origin patterns — `.test()` is stateful

```ts
export const [csrfMiddleware] = createCsrfMiddleware();
// app/root.tsx or app/routes/_ui.tsx
export const middleware: Route.MiddlewareFunction[] = [csrfMiddleware];
```
