---
source: remix
category: ui-components
---
# Client Hints — Prevent SSR Theme Flash

Use `@epic-web/client-hints` to prevent hydration mismatches for user preferences (theme, timezone).
- Inject `<ClientHintCheck>` in `<head>` before render
- Forces a page reload if cookie hint is missing or stale — ensures server and client match
- Parse color scheme in root loader; inject `className={colorScheme === 'dark' ? 'dark' : ''}` on `<html>`
