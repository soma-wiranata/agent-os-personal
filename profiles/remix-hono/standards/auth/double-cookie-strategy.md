---
source: hono
category: auth
---
# Double Cookie Strategy

Use a double-cookie pattern for auth tokens and abstract cookie operations behind `tokenActions`.

```typescript
export const tokenActions = {
  saveToCookie(token: string, c: Context) {
    setCookie(c, 'access-token', token, { httpOnly: true, secure: true })
  },
  saveUserToCookie(user: EnvUser, c: Context) {
    setCookie(c, 'user-data', encodeURI(JSON.stringify(user)), { httpOnly: false, secure: true })
  },
}
```

- `access-token`: always `httpOnly: true` (server-only security)
- `user-data`: `httpOnly: false` so the frontend can read the payload synchronously without an extra `/me` fetch
- Never call `getCookie`, `setCookie`, or `hono/jwt` directly inside route handlers — always route through `tokenActions`
