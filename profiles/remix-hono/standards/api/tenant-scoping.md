---
source: hono
category: api
---
# Tenant Scoping

All multi-tenant API endpoints must enforce workspace isolation and filter soft-deleted records.

```typescript
const workspaceId = c.get('workspace').id
const record = await db.select().from(monitor).where(
  and(eq(monitor.workspaceId, workspaceId), isNull(monitor.deletedAt))
)
```

- Always fetch tenant ID from context (`c.get('workspace').id`) — never from request body
- Always filter with `isNull(table.deletedAt)` for active-record queries
