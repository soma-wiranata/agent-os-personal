---
source: hono
category: database
---
# Soft Deletes

Use a `deletedAt` (timestamp) column for deletion. Never physically delete rows.

```typescript
// Delete: set deletedAt
await db.update(monitor).set({ deletedAt: new Date() }).where(eq(monitor.id, id))

// Query: always filter active records
.where(and(eq(monitor.workspaceId, workspaceId), isNull(monitor.deletedAt)))
```

- Always filter active-record queries with `isNull(table.deletedAt)` — add this to every query
- When indexing a soft-delete table, scope partial indexes to exclude deleted rows: `.where(sql\`${t.deletedAt} IS NULL\`)`
- Allows data restoration (recycle bin) and maintains referential integrity
