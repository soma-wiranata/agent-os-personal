---
source: hono
category: database
---
# Relational Mappings

Define entity relations explicitly in a companion `relations()` call alongside the table definition.

```typescript
export const monitorRelation = relations(monitor, ({ one }) => ({
  workspace: one(workspace, { fields: [monitor.workspaceId], references: [workspace.id] }),
}))
```

- Do not rely solely on foreign key constraints for Drizzle relational queries
- Place `relations()` calls immediately after their respective table definitions in the schema file
