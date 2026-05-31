---
source: shared
category: database
---
# Migrations Generate vs Push

Use `drizzle-kit generate` and `drizzle-kit migrate` for production schema updates, restricting `drizzle-kit push` exclusively to local development.

```bash
# Run migration tools from the workspace root
pnpm --filter @repo/db db:generate
pnpm --filter @repo/db db:migrate
```

- Running `db:generate` creates incremental SQL migration files inside `packages/db/migrations/` based on schema shifts.
- Executing `db:migrate` on deployment runs all pending SQL files safely against production database targets.
- Restricts direct schema synchronization commands (`db:push`) strictly to local databases and test databases.
