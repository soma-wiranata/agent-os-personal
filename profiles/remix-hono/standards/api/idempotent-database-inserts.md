---
source: hono
category: api
---
# Idempotent Database Inserts

Use database-level upserts (`onConflictDoUpdate` / `onConflictDoNothing`) for webhook and polling ingestion routes.

```typescript
await db.insert(repositories).values({ id, name }).onConflictDoUpdate({
  target: repositories.id,
  set: { name },
})
```

- Webhook delivery is "at least once" — the same event may arrive multiple times
- Never use "check then insert" — it races; handle conflicts at the DB level
- Always declare an explicit `target` constraint column and `set` fields to update
