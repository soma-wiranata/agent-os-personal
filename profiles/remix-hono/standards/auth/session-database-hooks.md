---
source: hono
category: auth
---
# Session Database Hooks

Use `databaseHooks` to automatically inject additional metadata into session objects at creation time.

```typescript
databaseHooks: {
  session: {
    create: {
      before: async (session) => ({
        data: { ...session, activeOrganizationId: await getActiveOrg(session.userId) },
      }),
    },
  },
}
```

- Ensures custom session data (e.g., `activeOrganizationId`) is populated at the DB level without extra client round-trips
- Prefer hooks over adding a middleware that re-queries session data on every request
