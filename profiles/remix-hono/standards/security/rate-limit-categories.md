---
source: hono
category: security
---
# Rate Limit Categories

Register separate, scoped `hono-rate-limiter` configurations for authentication, write operations, and read operations instead of one global limiter.

```typescript
import { rateLimiter } from 'hono-rate-limiter';

export const authLimiter = rateLimiter({
  windowMs: 15 * 60 * 1000, // 15 minutes
  limit: 10,
  standardHeaders: 'draft-7',
});
```

- Scopes authentication traffic under `/api/auth/*` to a strict limit of 10 requests per 15 minutes.
- Configures write actions (POST/PUT/PATCH/DELETE) on `/api/*` to a threshold of 60 requests per minute.
- Configures read actions (GET) on `/api/*` to a capacity of 200 requests per minute.
