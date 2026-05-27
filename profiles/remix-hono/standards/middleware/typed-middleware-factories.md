---
source: hono
category: middleware
---
# Typed Middleware Factories

Always use `createMiddleware<Env, Path>` from `hono/factory` for all custom middleware.

```typescript
import { createMiddleware } from 'hono/factory'
import type { HonoEnv } from '../types'

export const dbMiddleware = createMiddleware<HonoEnv, '*'>(async (c, next) => {
  c.set('db', getDbInstance(c.env.DATABASE_URL))
  await next()
})
```

- Provides type safety for `c.env` and `c.var` within the middleware
- Use `'*'` for the path generic if the middleware applies to all routes
- Never write generic `(c, next) => {}` middleware functions
