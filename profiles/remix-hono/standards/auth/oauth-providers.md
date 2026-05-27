---
source: remix
category: auth
---
# OAuth Providers — Plugin Registration

Register OAuth strategies on the `authenticator` singleton. New providers extend the `providers` map.
- Each provider implements `getAuthStrategy()` — returns `null` to disable itself
- `providerNames` array drives the OAuth button UI — never hardcode provider lists in components
- OAuth callback routes live in `_auth/auth.$provider/`
