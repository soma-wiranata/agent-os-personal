---
source: remix
category: real-time
---
# CORS — Middleware for More Than 2 Routes

Use `createCorsMiddleware` globally for consistent CORS. Use per-loader `cors()` only for 1-2 specific API routes.
- `origin: true` allows any origin — always restrict in production
- Preflight `OPTIONS` requests are handled automatically
