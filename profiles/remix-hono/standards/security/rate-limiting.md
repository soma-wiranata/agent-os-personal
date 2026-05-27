---
source: hono
category: security
---
# Rate Limiting

Apply `hono-rate-limiter` as scoped route-group middleware — never as a single global limiter.

---

### Rate Limit Categories

Register a separate limiter per traffic category. Apply each as middleware on its route group, not globally.

| Category | Scope | Limit |
|---|---|---|
| `authLimiter` | `/api/auth/*` | 10 req / 15 min |
| `writeLimiter` | POST / PUT / PATCH / DELETE on `/api/*` | 60 req / min |
| `readLimiter` | GET on `/api/*` | 200 req / min |

```typescript
import { rateLimiter } from 'hono-rate-limiter'

export const authLimiter = rateLimiter({
  windowMs:        15 * 60 * 1000,
  limit:           10,
  standardHeaders: 'draft-7',
  keyGenerator:    (c) =>
    c.req.header('x-forwarded-for') ??
    c.req.raw.headers.get('cf-connecting-ip') ??
    'unknown',
})
```

- Always set `standardHeaders: 'draft-7'` — returns `RateLimit-*` headers so clients can back off gracefully
- The `'unknown'` fallback buckets requests with no identifiable origin together, not into a shared unlimited pool — this is intentional and safe

---

### Key Extraction

Key on user ID for authenticated routes. Key on IP headers for unauthenticated routes.

```typescript
// Authenticated routes
keyGenerator: (c) => c.get('user').id

// Unauthenticated routes — prefer CF header, fall back to forwarded, then unknown
keyGenerator: (c) =>
  c.req.raw.headers.get('cf-connecting-ip') ??
  c.req.header('x-forwarded-for') ??
  'unknown'
```

- Never use `|| 'ip'` as a fallback — the literal string `'ip'` buckets all unidentified requests into one shared key, effectively bypassing per-user limits
- Never key on IP for authenticated routes — shared IPs (offices, proxies) will trigger limits for unrelated users

---

### 429 Response Shape

Always return the standard error envelope on rate limit exceeded — never let the library return a raw string.

```typescript
export const writeLimiter = rateLimiter({
  // ...
  handler: (c) =>
    c.json({ success: false, error: { message: 'Too many requests', code: 'RATE_LIMITED' } }, 429),
})
```

---

### Store Configuration

- **Cloudflare Workers:** use Cloudflare KV as the limiter store — in-memory state doesn't persist across worker instances
- **Node / Bun production:** use Redis
- **Local development:** default in-memory store is fine — never configure Redis locally just for rate limiting
