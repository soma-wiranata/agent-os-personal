---
source: remix
category: ui-components
---
# Route Handle Pattern — Typed Metadata via `handle` Export

Use the `handle` export for route-specific metadata (sitemap entries, breadcrumbs, layout flags). Read with `useMatches()` in root or parent routes.
- Define a typed `Handle` type for the project — do not use untyped object literals
