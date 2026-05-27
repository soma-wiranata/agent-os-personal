---
source: remix
category: routing
---
# Config-Based Routing for Complex Cases

Use `app/routes.ts` with `route()` / `index()` when mapping multiple disparate URLs to one component or managing complex nested layouts.
- Useful for legacy URL patterns, markdown-driven routes, or multi-version doc sites
- File-based convention is preferred for standard CRUD routes; config-based is preferred when one layout serves many content URLs
