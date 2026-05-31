---
source: hono
category: api
---
# Response Helpers

Always use the `ok(c, data)` and `fail(c, message, code)` helper utilities to return standard response shapes instead of manually constructing ad-hoc JSON objects.

```typescript
// src/lib/response.ts
import { Context } from 'hono';

export const ok = <T>(c: Context, data: T, status = 200) =>
  c.json({ success: true, data }, status);

export const fail = (c: Context, message: string, code?: string, status = 400) =>
  c.json({ success: false, error: { message, code } }, status);
```

- Enforces response envelope consistency across all public-facing backend endpoints.
- Prevents raw JSON returns that break the end-to-end client-side type contract.
- Integrates seamlessly with the standard payload shapes defined in the API response envelope.
