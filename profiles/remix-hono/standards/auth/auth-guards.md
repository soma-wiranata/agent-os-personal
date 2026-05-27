---
source: remix
category: auth
---
# Auth Guards — `requireUserId` and `requireAnonymous`

Use auth guard utilities at the top of every loader and action. Never inline auth logic in routes.
- `requireUserId` preserves current URL as `redirectTo` param unless `{ redirectTo: null }` is passed
- `requireAnonymous` guards login/signup/forgot-password routes — throws if already authenticated
- For role checks, use `requireUserWithPermission` — never `requireUserId` + manual check
