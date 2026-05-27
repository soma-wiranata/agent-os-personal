---
source: shared
category: api
---
# E2E Type-Safe RPC Bridge

Use `hono/client` (`hc`) to call Hono API routes from Remix loaders and actions with full type safety — no schema duplication, no tRPC.

---

### Export `AppType` via Shared Package

Export `AppType` as a type-only export from the chained `.route()` return — never from the raw `app` instance.

```typescript
// apps/api/src/index.ts
const routes = app
  .route('/api/items', itemsModule)
  .route('/api/users', usersModule)

export type AppType = typeof routes
export default app
```

Re-export from `packages/types` so `apps/web` has no direct dependency on `apps/api`:

```typescript
// packages/types/src/index.ts
export type { AppType } from '../../apps/api/src/index'
```

- `AppType` derived from chained routes captures all route types; the bare `app` does not
- The `packages/types` re-export is what `apps/web` imports — never import directly from `apps/api`

---

### Instantiate the Client Once, Server-Side

Create a single `hc<AppType>` instance in `apps/web/app/lib/api.server.ts`. The `.server.ts` extension prevents this file from reaching the client bundle.

- Import the client singleton from `~/lib/api.server` in all loaders and actions — never call `hc()` inline in route files
- `API_BASE_URL` must be a server-only env var — never expose it to the client

---

### Consuming the Client in Loaders and Actions

Always check `json.success` before accessing `json.data`. On failure, throw a Remix `Response` to delegate to the nearest `ErrorBoundary`.

```typescript
// apps/web/app/modules/items/queries.server.ts
import { api } from '~/lib/api.server'

export async function getItems(limit = 10) {
  const res  = await api.api.items.$get({ query: { limit: String(limit) } })
  const json = await res.json()

  if (!json.success) {
    throw new Response(json.error.message, { status: res.status })
  }

  return json.data.items
}
```

- Never return `json.error` to the component — throw it so `ErrorBoundary` handles it
- Never `await res.json()` without checking `res.ok` or `json.success` — a non-200 without `json.success` check silently passes bad data through
