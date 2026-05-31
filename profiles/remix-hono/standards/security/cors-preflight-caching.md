---
source: hono
category: security
---
# CORS Preflight Caching

Always configure `maxAge: 86400` (24 hours) in all CORS setups to allow browsers to cache preflight OPTIONS requests.

```typescript
import { cors } from 'hono/cors';

export const apiCors = cors({
  origin: 'https://app.example.com',
  maxAge: 86400, // 24 hours in seconds
});
```

- Bypasses duplicate browser OPTIONS preflight requests, drastically reducing round-trip latency for API actions.
- Reduces backend traffic load by ensuring both production and development browsers cache preflight permissions.
- Prevents cross-origin performance degradation on critical application API pathways.
