---
source: hono
category: api
---
# Global Error & 404 Handlers

Register `app.notFound()` and `app.onError()` once in `createApp()` before any routes.

```typescript
import { notFound, onError } from 'stoker/middlewares'
app.notFound(notFound)
app.onError(onError)
```

- Use `stoker/middlewares` defaults unless you have specific custom logging requirements
- Never handle generic errors inside individual route handlers via `try/catch`
