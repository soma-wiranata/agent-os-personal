---
source: remix
category: database
---
# Singleton Prisma Client via `@epic-web/remember`

Export a single `prisma` instance from `app/utils/db.server.ts` using `remember()`. Never instantiate `PrismaClient` anywhere else.
- Import from `@prisma/client/index.js` (not `@prisma/client`) due to a known React Router/HMR issue
- The slow query threshold is 20ms — log anything exceeding it with color-coded severity

```ts
export const prisma = remember('prisma', () => new PrismaClient({ log: [...] }))
```
