---
source: remix
category: security
---
# Secure Headers — Apply at Root

Apply `createSecureHeadersMiddleware` once at root for global coverage.
- `X-Content-Type-Options: nosniff`, `X-Frame-Options: SAMEORIGIN`, `Strict-Transport-Security`, etc. — all applied by default
- `Cross-Origin-Embedder-Policy` is disabled by default — enables CDN/embed compatibility
- If embedding in iframes, override `xFrameOptions: false`
- `removePoweredBy` defaults to `true` — keep enabled to hide server identity
