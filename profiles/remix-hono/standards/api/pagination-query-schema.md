---
source: shared
category: api
---
# Pagination Query Schema

Define a shared `paginationQuerySchema` in `packages/db` and validate it using Hono's `zValidator` middleware.

```typescript
import { z } from 'zod';

export const paginationQuerySchema = z.object({
  cursor: z.string().optional(),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});
```

- Enforces that the `cursor` param is an opaque base64 composite string rather than exposing raw primary key columns.
- Prevents loading unvalidated, uncoerced strings by enforcing Zod validation on incoming request queries.
- Protects database performance by restricting client limits to a maximum boundary of 100 records.
