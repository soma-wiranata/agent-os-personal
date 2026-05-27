---
source: remix
category: ui-components
---
# Root Layout — `Layout` and `App` Are Always Separate

`root.tsx` exports `Layout` (document shell) and `App` (route tree) as separate functions.
- `Layout` wraps error boundaries — it must be independent of loader data
- Import CSS with `?url` suffix in `links()` — never via bare import (won't be injected into `<head>` correctly)
- `<ScrollRestoration />` must be inside `<body>` before `<Scripts />`
