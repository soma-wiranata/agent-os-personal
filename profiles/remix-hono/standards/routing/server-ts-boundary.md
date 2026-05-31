---
source: remix
category: routing
---
# Server TS Boundary

Always append the `.server.ts` or `.server.tsx` extension to any file containing direct database queries, private environment variables, or server-only dependencies.

```typescript
// app/modules/tasks/queries.server.ts
import { db } from '../shared/db.server';
import { tasksTable } from './schema';

export async function getTasks() {
  return db.select().from(tasksTable);
}
```

- Enforces a strict compile-time boundary where Vite automatically strips matching server files from client-side bundles.
- Prevents server-only environment variables, credentials, and business logic from leaking to client browsers.
- Prevents bloat in client bundles by ensuring database clients and heavy node modules are never hydrated.
