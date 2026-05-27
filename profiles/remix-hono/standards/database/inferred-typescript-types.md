---
source: hono
category: database
---
# Inferred TypeScript Types

Export inferred TypeScript types directly from Drizzle schemas — never maintain separate interface files.

```typescript
// db/schema.ts
export const repositories = pgTable('repositories', { ... })
export type Repository = typeof repositories.$inferSelect
export type RepositoryInsert = typeof repositories.$inferInsert
```

- Keeps TypeScript types perfectly in sync with the DB schema automatically
- Export both `$inferSelect` and `$inferInsert` for every table
