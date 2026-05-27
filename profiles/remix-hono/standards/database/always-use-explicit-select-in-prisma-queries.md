---
source: remix
category: database
---
# Always Use Explicit `select` in Prisma Queries

Every Prisma query must specify an explicit `select`. Never fetch full model objects.
- Never return `password.hash` or sensitive fields to the client — explicit `select` enforces this at the query level
- Nested relations also need explicit `select` — do not assume they're excluded

```ts
// ✅ const user = await prisma.user.findUnique({ select: { id: true, name: true }, where: { id } })
// ❌ const user = await prisma.user.findUnique({ where: { id } }) // leaks password hash
```
