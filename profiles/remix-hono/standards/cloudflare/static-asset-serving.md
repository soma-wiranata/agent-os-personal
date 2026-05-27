---
source: hono
category: cloudflare
---
# Static Asset Serving

Use `serveStatic` from `hono/cloudflare-workers` to serve Vite-built client assets.

```typescript
import { serveStatic } from 'hono/cloudflare-workers'

app.use('/assets/*', serveStatic({ root: './dist/client', manifest: {} }))
```

- The empty `manifest: {}` object is a required API parameter for Cloudflare Workers' `serveStatic`
- Ensure `root` path matches your Vite `build.outDir`
