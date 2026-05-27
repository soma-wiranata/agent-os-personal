---
source: hono
category: api
---
# Asynchronous Background Processing

Never pass the Hono request context `c` into fire-and-forget background execution chains.

```typescript
app.get('/checker/:period', async (c) => {
  const period = c.req.param('period')   // ✓ extract primitives first
  void runInBackground(period)           // ✓ no `c` captured
  return c.json({ success: period }, 200)
})
```

- Extract all path params, queries, and headers into local primitive variables before launching background work
- Use a global/background error reporter (not request-scoped telemetry) inside background chains
- Return the HTTP response immediately after launching — never `await` background work
