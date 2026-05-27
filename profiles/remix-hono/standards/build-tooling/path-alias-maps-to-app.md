---
source: remix
category: build-tooling
---
# Path Alias `~/` Maps to `./app/*`

Use `~/` everywhere — never use relative paths to reach into `app/`.
- Configure in both `tsconfig.json` (`paths`) and via `vite-tsconfig-paths` plugin
- Do not duplicate with a manual `resolve.alias` in Vite config — `vite-tsconfig-paths` handles it
