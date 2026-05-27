---
source: hono
category: database
---
# Cloudflare Hyperdrive / PostgreSQL

When connecting to PostgreSQL from Cloudflare Workers, always use the `getDbForHono(c)` utility.

```typescript
const db = await getDbForHono(c)
```

- Abstracts Hyperdrive (production) vs. direct PostgreSQL URL (local dev) — never switch manually
- The Drizzle instance is configured with `client: pool` for proper connection cleanup
