---
source: hono
category: cloudflare
---
# Hono SSR on the Edge

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
