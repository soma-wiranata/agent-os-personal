---
source: remix
category: headers-caching
---
# Flash Toasts via Cookie Session

Communicate post-redirect notifications via a dedicated flash cookie session. Never use URL params for one-time notifications.
- Types: `message` (neutral), `success` (green), `error` (red)
- `getToast` destroys the toast session after reading — it is flash-only
- `EpicToaster` is rendered in `root.tsx` once — never add to individual routes

```ts
return redirectWithToast('/dashboard', { title: 'Success', description: '...', type: 'success' })
```
