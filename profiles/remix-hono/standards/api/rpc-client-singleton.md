---
source: shared
category: api
---
# RPC Client Singleton

Instantiate the Hono client `hc<AppType>` exactly once inside a server-only `api.server.ts` utility file instead of calling `hc()` inline.

```typescript
// apps/web/app/lib/api.server.ts
import { hc } from 'hono/client';
import type { AppType } from '@repo/types';

export const api = hc<AppType>(process.env.API_BASE_URL!);
```

- Prevents duplicate connection configurations and ensures the RPC client is shared efficiently.
- Using a `.server.ts` extension guarantees that client-creation logic is completely excluded from the browser bundle.
- Protects the `API_BASE_URL` by keeping it as a strictly server-side environment variable.
