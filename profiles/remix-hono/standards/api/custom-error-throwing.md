---
source: hono
category: api
---
# Custom Error Throwing

Throw structured custom errors from business logic — never return `c.json({ error })` manually inside handlers.

```typescript
import { CommonErrors } from '@/middleware'
if (!user) throw CommonErrors.notFound('User')
if (!hasAccess) throw CommonErrors.forbidden('Requires admin access')
```

- Custom error classes carry a `statusCode`, `code` string, and optional `details`, mapping cleanly to the response envelope
- The universal `app.onError()` handler formats and sanitizes these automatically
- In development: includes full stack traces. In production: strips internals, shows generic messages
