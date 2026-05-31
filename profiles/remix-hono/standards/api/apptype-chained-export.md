---
source: shared
category: api
---
# AppType Chained Export

Export the Hono `AppType` type-only signature from the return value of chained `.route()` calls, rather than from the raw unchained `app` instance.

```typescript
// apps/api/src/index.ts
const routes = app
  .route('/api/items', itemsModule)
  .route('/api/users', usersModule);

export type AppType = typeof routes;
export default app;

// packages/types/src/index.ts
export type { AppType } from '../../apps/api/src/index';
```

- Chaining route registrations collects the full type maps of nested sub-routers, which the bare `app` instance fails to capture.
- Re-exporting `AppType` through a shared type package prevents the frontend from directly depending on backend source files.
- Provides automatic, end-to-end type inference on HTTP routes without code generation overhead.
