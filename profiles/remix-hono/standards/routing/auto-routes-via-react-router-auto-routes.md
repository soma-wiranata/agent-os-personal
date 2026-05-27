---
source: remix
category: routing
---
# Auto-Routes via `react-router-auto-routes`

Use `autoRoutes()` in `app/routes.ts`. Never declare routes manually unless there is no filesystem equivalent.
- Files suffixed `.server.*` or `.client.*` are excluded from routing automatically
- Run `react-router typegen` after adding or renaming routes to regenerate `+types/`
