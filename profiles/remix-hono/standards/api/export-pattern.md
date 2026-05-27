---
source: hono
category: api
---
# Export Pattern

The main app entry always exports the default `app` instance.

```typescript
export default app
```

- Required for Cloudflare Workers, Bun, and `serve` deployments
- Never mix named exports for the primary app instance unless a specific adapter requires it
