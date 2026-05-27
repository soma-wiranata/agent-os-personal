---
source: hono
category: cloudflare
---
# Grammy Webhook Integration (Telegram Bots)

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
