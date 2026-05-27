---
source: hono
category: auth
---
# Cloudflare Workers Auth Setup

When configuring `better-auth` for Cloudflare Workers, wrap configuration using `withCloudflare`.

```typescript
const auth = betterAuth(withCloudflare({
  autoDetectIpAddress: true,
  d1: { db: dbInstance },
  kv: env.KV,
}, { /* other better-auth configs */ }))
```

- Cloudflare D1/Hyperdrive and KV bindings work differently than Node.js — the wrapper safely integrates them into `better-auth`'s adapter
