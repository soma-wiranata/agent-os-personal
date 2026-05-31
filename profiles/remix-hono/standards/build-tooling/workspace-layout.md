---
source: shared
category: build-tooling
---
# Workspace Layout

Use PNPM Workspaces and Turborepo with the canonical `apps/` and `packages/` directory layout to manage applications and internal packages.

```text
/
├── apps/
│   ├── web/               # React Router v7 (Remix)
│   └── api/               # Hono backend
├── packages/
│   ├── db/                # Drizzle schema, migrations, client factory
│   └── types/             # Shared TS types — AppType for RPC
├── turbo.json
├── pnpm-workspace.yaml
└── package.json           # Root: dev tooling only
```

- Groups client/server applications into `apps/` and reusable library blocks into `packages/`.
- Configures workspace resolutions via `pnpm-workspace.yaml` mapping to `'apps/*'` and `'packages/*'`.
- Restricts the root package manifest strictly to monorepo-wide developer tooling, avoiding runtime dependency leaks.
