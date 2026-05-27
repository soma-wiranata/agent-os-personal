---
source: shared
category: build-tooling
---
# Monorepo Workspace Structure

Use PNPM Workspaces + Turborepo for all projects. This is the canonical layout:

```text
/
├── apps/
│   ├── web/               # React Router v7 (Remix)
│   └── api/               # Hono backend
├── packages/
│   ├── db/                # Drizzle schema, migrations, client factory, Zod schemas
│   ├── types/             # Shared TS types — AppType for RPC, domain interfaces
│   └── ui/                # Optional: shadcn/ui component library
├── turbo.json
├── pnpm-workspace.yaml
└── package.json           # Root: dev tooling only (biome, turbo, tsx)
```

```yaml
# pnpm-workspace.yaml
packages:
  - 'apps/*'
  - 'packages/*'
```

---

### Shared Package Boundaries

Never import from `apps/*` across app boundaries — only `packages/*` are shared.

- `packages/db` exports: Drizzle client factory, all table schemas, all `$inferSelect`/`$inferInsert` types, and all Zod validation schemas — both apps import from here
- `packages/types` exports: `AppType` (Hono RPC contract) and any shared domain interfaces — keeps `apps/web` free of a direct dependency on `apps/api`
- Root `package.json` holds only tooling (`biome`, `turbo`, `tsx`) — never runtime dependencies

---

### Turborepo Pipeline

Define consistent task names across all packages. The `turbo.json` pipeline must reflect these dependency rules:

```json
{
  "tasks": {
    "build": { "dependsOn": ["^build"], "outputs": ["dist/**"] },
    "dev":   { "persistent": true, "cache": false },
    "typecheck": { "dependsOn": ["^build"] },
    "test":  { "dependsOn": ["^build"] },
    "lint":  {}
  }
}
```

- `build` depends on upstream `^build` — `apps/web` won't build until `packages/db` and `packages/types` are built first
- `dev` is `persistent: true` and never cached — it runs all dev servers in parallel
- Never add a task name in one package that doesn't exist in others — Turbo silently skips missing tasks
