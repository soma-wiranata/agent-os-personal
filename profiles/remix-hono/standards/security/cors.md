---
source: hono
category: security
---
# Cross-Origin Resource Sharing (CORS)

Apply a restrictive, scoped CORS middleware to general API routes. Auth-route CORS is handled separately in `auth.md`.

---

### Scoped API CORS

Apply CORS only to `/api/*` routes (excluding `/api/auth/*`). Never use a single global CORS middleware for the entire app.

```typescript
import { cors } from 'hono/cors'

export const apiCors = cors({
  origin: (origin, c) => {
    // Cloudflare Workers: use c.env  |  Node/Bun: use process.env
    const raw     = c.env?.ALLOWED_ORIGINS ?? process.env.ALLOWED_ORIGINS
    const allowed = raw?.split(',') ?? ['http://localhost:5173']
    return allowed.includes(origin) ? origin : null
  },
  credentials: false,
  maxAge: 86400,
})
```

- `credentials: false` for all data API routes — only auth routes require `credentials: true`
- Never use `origin: '*'` on any route — explicit allowlist only
- `ALLOWED_ORIGINS` is a comma-separated env var in production (e.g. `https://app.example.com,https://www.example.com`)

---

### Preflight Caching

Always set `maxAge: 86400` (24 hours) on every CORS config.

- Without `maxAge`, every cross-origin request fires a separate OPTIONS preflight round-trip
- No exceptions — even internal staging environments benefit from cached preflights

---

### Server-to-Server Route Exemption

Routes under `/internal/*` and `/webhooks/*` must explicitly opt out of CORS middleware.

- These routes are server-to-server only — a browser origin header is a signal of a misconfigured or spoofed request
- Protect them with a shared secret header or IP allowlist instead (covered in `api.md` — Internal Route Protection)
