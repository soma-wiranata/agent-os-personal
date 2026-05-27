---
source: remix
category: build-tooling
---
# Linting & Formatting — Biome, Not ESLint + Prettier

Use Biome for both linting and formatting. Never add ESLint or Prettier.
- `noUnusedVariables` is elevated to `error` (Biome default is `warn`)
- Enforce via Lefthook pre-commit running only on staged files with `stage_fixed: true`
