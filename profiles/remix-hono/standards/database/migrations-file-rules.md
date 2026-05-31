---
source: shared
category: database
---
# Migrations File Rules

Never manually edit or rename generated SQL migration files; always generate a new migration to apply downstream database alterations.

```text
packages/db/migrations/
├── 0000_init.sql
└── 0001_add_index.sql
```

- Keeps all generated migration scripts inside `packages/db/migrations/` with stable timestamp prefixes.
- Committing migration files directly to git ensures schema history is completely trackable across branches.
- Prevents database sync divergence and cryptographic checksum mismatches in deployment runtimes.
