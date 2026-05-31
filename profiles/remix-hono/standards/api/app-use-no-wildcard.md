---
source: hono
category: api
---
# App Use No Wildcard

Never pass a wildcard path pattern `'*'` to `app.use()` when registering global middleware, as global scoping is implicit in modern Hono.

```typescript
import { Hono } from 'hono';
import { logger } from 'hono/logger';

const app = new Hono();

// Good: Implicitly global
app.use(logger());

// Bad: Explicit wildcard is redundant
app.use('*', logger());
```

- Passing `'*'` is a redundant no-op that can mislead readers into thinking complex route matching is applied.
- Aligns with modern Hono standards which implicitly treat a single argument as global-level middleware.
- Simplifies boilerplate in the application entrypoint and middleware configurations.
