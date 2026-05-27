---
source: shared
category: database
---
# Database Migrations

Use `drizzle-kit generate` + `drizzle-kit migrate` in production. All migration SQL is committed to git and applied automatically on deploy.

---

### Generate vs Push

`drizzle-kit push` is for local dev and test environments only — never CI, never production.

| Command | When to use |
|---|---|
| `db:generate` | After any schema change — produces a SQL file in `packages/db/migrations/` |
| `db:migrate` | On deploy — applies pending SQL files to the target database |
| `db:push` | Local dev and ephemeral test DBs only |
| `db:studio` | Local introspection only |

Define these scripts in `packages/db/package.json`:

```bash
# packages/db/package.json — scripts section
"db:generate" → drizzle-kit generate
"db:migrate"  → drizzle-kit migrate
"db:push"     → drizzle-kit push
"db:studio"   → drizzle-kit studio
```

Run from the repo root via:

```bash
pnpm --filter @repo/db db:generate
pnpm --filter @repo/db db:migrate
```

---

### Migration File Rules

Never manually edit a generated migration file — create a new one instead.

- Migration files live in `packages/db/migrations/` with Drizzle's timestamp-prefixed filenames — never rename them
- Commit every generated migration file to git — the migration history is part of the codebase

---

### Deploy Integration

Run migrations automatically on deploy — never manually via SSH.

- **Cloudflare D1:** `wrangler d1 migrations apply <DB_NAME> --remote` as a deploy step
- **Node / Bun:** run `db:migrate` as a startup script before the HTTP server binds
- The Drizzle client factory in `packages/db` must accept the connection string as an argument — never read `process.env` inside the shared package itself
