---
source: remix
category: security
---
# Safe Redirects — Always Wrap User-Controlled URLs

Always wrap user-controlled redirect values with `safeRedirect(value, fallback)`.
- Valid: `/dashboard`, `/settings/profile`
- Blocked: `https://evil.com`, `//evil.com`, `/\evil`, `../secret`
- Always provide a meaningful fallback — the default is `/`

```ts
return redirect(safeRedirect(redirectTo, '/dashboard'))
```
