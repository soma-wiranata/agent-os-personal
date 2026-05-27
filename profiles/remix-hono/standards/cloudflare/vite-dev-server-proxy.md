---
source: hono
category: cloudflare
---
# Vite Dev Server Proxy

Proxy `/api` requests to the Hono dev server via Vite config during local development.

```typescript
// vite.config.ts
export default defineConfig({
  server: { port: 5173, proxy: { '/api': { target: 'http://localhost:8787', changeOrigin: true } } },
})
```

- Keeps HMR (Vite) and backend (Wrangler) dev servers separate without CORS configuration overhead
- Production/cross-origin setups must explicitly configure `hono/cors` with trusted frontend origins
