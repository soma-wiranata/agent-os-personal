---
source: hono
category: api
---
# Context Helpers

Always use Hono's built-in `c` (Context) helpers for constructing responses instead of returning raw `Response` objects.

- Use `c.json()` for API endpoints, `c.text()` for plain text/webhooks, `c.html()` for HTML
- Use `c.notFound()` and `c.redirect()` for their respective behaviors
- Never return `new Response(JSON.stringify(...), { headers: {...} })` in any handler
