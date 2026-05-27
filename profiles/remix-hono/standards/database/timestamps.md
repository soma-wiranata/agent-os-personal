---
source: hono
category: database
---
# Timestamps

Every table must include `createdAt` and `updatedAt`. For PostgreSQL: use `withTimezone: true` and `mode: 'string'`. For SQLite: use `integer({ mode: 'timestamp' })`.

```typescript
// PostgreSQL (Drizzle + pg-core)
createdAt: timestamp('created_at', { withTimezone: true, mode: 'string' }).default(sql`CURRENT_TIMESTAMP`),
updatedAt: timestamp('updated_at', { withTimezone: true, mode: 'string' }).defaultNow().notNull().$onUpdate(() => sql`now()`),

// SQLite (Drizzle + sqlite-core)
createdAt: integer({ mode: 'timestamp' }).$defaultFn(() => new Date()),
updatedAt: integer({ mode: 'timestamp' }).$defaultFn(() => new Date()).$onUpdate(() => new Date()),
```

- `withTimezone: true` guarantees timezone-aware storage (`timestamptz`) in PostgreSQL
- `mode: 'string'` avoids JS `Date` inconsistencies across Cloudflare Worker/JSON boundaries
- Manage timestamps at the application level via `$defaultFn`/`$onUpdate` — avoid DB-side triggers
