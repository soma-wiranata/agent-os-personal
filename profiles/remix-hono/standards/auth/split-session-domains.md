---
source: remix
category: auth
---
# Split Session Domains

Split session logic into specialized domains — never put everything in one cookie.
- Authentication tracking → `getSession()` (main session)
- Auth UI flash state → `getLoginInfoSession()`
- Anonymous client ID → `getClientSession()`
- Always merge headers from all modified sessions before returning the response
