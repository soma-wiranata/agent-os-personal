---
source: hono
category: security
---
# CORS Scoped API

Apply CORS middleware strictly to `/api/*` paths (excluding `/api/auth/*`) using an environment-specific origin allowlist.

```typescript
import { cors } from 'hono/cors';

export const apiCors = cors({
  origin: (origin, c) => {
    const raw = c.env?.ALLOWED_ORIGINS ?? process.env.ALLOWED_ORIGINS;
    const allowed = raw?.split(',') ?? ['http://localhost:5173'];
    return allowed.includes(origin) ? origin : null;
  },
  credentials: false,
});
```

- Blocks credentials access (`credentials: false`) on general data endpoints, limiting cookie exposure strictly to authentication routes.
- Strictly prohibits wildcard `origin: '*'` values to secure resource interfaces from generic cross-site scripting vectors.
- Supports both edge and container deployments via the dual-runtime `c.env` or `process.env` resolution lookup.
