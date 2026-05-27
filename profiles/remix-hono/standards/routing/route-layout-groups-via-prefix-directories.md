---
source: remix
category: routing
---
# Route Layout Groups via `_prefix` Directories

Group routes by layout using underscore-prefixed directories. The prefix is stripped from the URL.
- `_auth/` → anonymous auth flows (login, signup, forgot-password)
- `_marketing/` → public-facing pages
- `resources/` → non-UI resource routes
- Never put auth-protected routes inside `_auth/` — the group is for anonymous screens only
