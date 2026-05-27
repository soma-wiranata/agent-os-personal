---
source: hono
category: database
---
# Cascading Deletes

Define `{ onDelete: 'cascade' }` in `.references()` for child entities that cannot exist without their parent.

```typescript
export const events = pgTable('events', {
  userId: integer('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
})
```

- Prevents orphaned rows and foreign key violations
- Eliminates manual application-side cleanup when parents are deleted
