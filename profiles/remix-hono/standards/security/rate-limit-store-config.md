---
source: hono
category: security
---
# Rate Limit Store Config

Configure rate limiting backend stores dynamically based on local development or targeted production runtime platforms.

```typescript
// Production store setups:
// - Cloudflare Workers: Use wrangler-scoped KVNamespace stores
// - Node / Bun containers: Use Redis client stores
// - Local development: Default to simple in-memory stores
```

- Bypasses local dependency overhead by restricting Redis or KV setups to staging/production environments.
- Ensures cross-worker state persistence on edge nodes via Cloudflare KV namespaces.
- Standardizes on scalable Redis caches for non-edge container clusters.
