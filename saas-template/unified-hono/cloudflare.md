# Cloudflare & Deployment Standards

## Rules

---

### Typed Environment Bindings

Always instantiate Hono apps with typed `Bindings` and `Variables` generics when deploying to Cloudflare Workers.

```typescript
type Env = { BOT_TOKEN: string; DB: D1Database; KV: KVNamespace }

const app = new Hono<{ Bindings: Env; Variables: { user: User | null } }>()
```

- Maintain a single central `types.ts` exporting `Bindings` and `Variables`
- Eliminates `c.env.MISSING_VAR` runtime failures through TypeScript enforcement
- Never access `process.env` directly — Cloudflare Workers bindings are only available on `c.env`

---

### Static Asset Serving

Use `serveStatic` from `hono/cloudflare-workers` to serve Vite-built client assets.

```typescript
import { serveStatic } from 'hono/cloudflare-workers'

app.use('/assets/*', serveStatic({ root: './dist/client', manifest: {} }))
```

- The empty `manifest: {}` object is a required API parameter for Cloudflare Workers' `serveStatic`
- Ensure `root` path matches your Vite `build.outDir`

---

### Hono SSR on the Edge

In full-stack SSR apps, use a catch-all route to dynamically import the server entry and inject initial state.

```typescript
app.get('*', async (c) => {
  const { render } = await import('../dist/server/entry-server.js')
  const { html, state } = await render(new URL(c.req.url).pathname, {})
  return c.html(`<!DOCTYPE html><html><body>
    <div id="root">${html}</div>
    <script>window.__INITIAL_STATE__ = ${state}</script>
    <script type="module" src="/assets/client.js"></script>
  </body></html>`)
})
```

- Never reference browser globals (`window`, `document`) during the server render phase — this crashes the worker
- Always wrap in `try/catch` and return a 500 HTML response on SSR failure

---

### Vite Dev Server Proxy

Proxy `/api` requests to the Hono dev server via Vite config during local development.

```typescript
// vite.config.ts
export default defineConfig({
  server: { port: 5173, proxy: { '/api': { target: 'http://localhost:8787', changeOrigin: true } } },
})
```

- Keeps HMR (Vite) and backend (Wrangler) dev servers separate without CORS configuration overhead
- Production/cross-origin setups must explicitly configure `hono/cors` with trusted frontend origins

---

### Grammy Webhook Integration (Telegram Bots)

When integrating Grammy with Hono on Cloudflare Workers, instantiate the bot inside the route handler — never at module level.

```typescript
app.post('/webhook', async (c) => {
  const bot = new Bot(c.env.BOT_TOKEN)   // ← per-request, uses c.env
  bot.command('start', (ctx) => ctx.reply('Hello!'))
  const handler = webhookCallback(bot, 'hono')
  return await handler(c)
})
```

- Cloudflare Workers pass env vars per-request via `c.env` — module-level bot instances don't have access
- Use `webhookCallback(bot, 'hono')` — the built-in Grammy adapter for Hono's request/response format
