---
source: remix
category: auth
---
# Permission Strings — `action:entity:access`

Encode permissions as typed strings in format `action:entity` or `action:entity:access`.
- `own` = the user's own records only; `any` = any record (admin level)
- Check permissions in loaders/actions via `requireUserWithPermission`; on the client via `userHasPermission(user, ...)`
- Never query permissions directly in component code

```ts
type PermissionString = `${Action}:${Entity}` | `${Action}:${Entity}:${Access}`
// Server: await requireUserWithPermission(request, 'read:note:own')
// Client: userHasPermission(user, 'delete:note:any')
```
