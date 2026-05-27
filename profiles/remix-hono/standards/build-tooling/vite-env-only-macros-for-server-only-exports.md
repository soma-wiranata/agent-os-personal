---
source: remix
category: build-tooling
---
# `vite-env-only` Macros for Server-Only Exports

Use `serverOnly$` and `clientOnly$` from `vite-env-only` to guarantee dead-code elimination in shared files.
- `.server.ts` files are automatically excluded from client bundles by React Router
- The macro is for inline usage within shared files where static analysis cannot determine the scope

```ts
export const DB_URL = serverOnly$(process.env.DATABASE_URL)  // undefined in client bundle
```
