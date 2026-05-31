---
source: hono
category: security
---
# Rate Limit 429 Response

Configure all rate limit instances to output the standard success-false JSON envelope when request thresholds are breached.

```typescript
import { rateLimiter } from 'hono-rate-limiter';

export const limiter = rateLimiter({
  handler: (c) =>
    c.json({
      success: false,
      error: { message: 'Too many requests', code: 'RATE_LIMITED' }
    }, 429),
});
```

- Guarantees rate limiting failures fit within the standard JSON envelope structure expected by clients.
- Prevents raw string outputs from breaking automatic JSON deserialization in fetch clients.
- Exposes a dedicated `RATE_LIMITED` code payload to let front-end UI systems pause actions or display toasts.
