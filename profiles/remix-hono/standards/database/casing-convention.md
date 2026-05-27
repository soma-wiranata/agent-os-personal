---
source: hono
category: database
---
# Casing Convention

Use `camelCase` in TypeScript and `snake_case` in the database. Set `casing: 'snake_case'` in the Drizzle client.

```typescript
// db/index.ts
const db = drizzle({ casing: 'snake_case' })

// db/schema.ts
export const tasks = sqliteTable('tasks', {
  createdAt: integer({ mode: 'timestamp' })  // TS: createdAt, DB: created_at
})
```

- Map explicitly in schema definitions using the snake_case column name string when in doubt
- Overrides are discouraged unless interfacing with a legacy schema
