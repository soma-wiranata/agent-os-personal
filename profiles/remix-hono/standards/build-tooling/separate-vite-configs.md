---
source: remix
category: build-tooling
---
# Separate Vite Configs — Never Merge

Use separate config files for dev/prod build, Vitest, and Storybook. Never merge them.
- The Remix/React Router Vite plugin intercepts module resolution and SSR transforms — it breaks Vitest and Storybook environments
- `installGlobals()` must be called at module top-level in `vite.config.ts`

| File | Purpose | Remix Plugin |
|---|---|---|
| `vite.config.ts` | Dev + prod | ✅ |
| `vitest.config.ts` | Unit tests | ❌ |
| `vite-sb.config.ts` | Storybook | ❌ |
