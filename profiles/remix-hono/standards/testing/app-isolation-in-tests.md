---
source: hono
category: testing
---
# App Isolation in Tests

Use `createTestApp(router)` to mount individual routers for testing — never import the global `app`.

```typescript
import { createTestApp } from '@/lib/create-app'
import router from './tasks.index'

const client = testClient(createTestApp(router))
```

- Isolates the router with only the necessary global middlewares
- Prevents unwanted side effects from other routes; keeps tests faster
- Testing the global `app` instance is only necessary for app-level logic (e.g., static file serving)
