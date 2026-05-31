---
source: shared
category: api
---
# RPC Error Propagation

Always check the `success` field of the deserialized RPC response and throw a `Response` on failure to trigger the nearest error boundary.

```typescript
// apps/web/app/modules/items/queries.server.ts
import { api } from '~/lib/api.server';

export async function getItems(limit = 10) {
  const res = await api.api.items.$get({ query: { limit: String(limit) } });
  const json = await res.json();

  if (!json.success) {
    throw new Response(json.error.message, { status: res.status });
  }

  return json.data.items;
}
```

- Blocks invalid or corrupted payloads from leaking into UI components, ensuring data safety.
- Keeps route components highly focused on rendering by shifting error presentation to `ErrorBoundary` components.
- Guarantees unexpected failures or bad API statuses are never ignored during server-side load sequences.
