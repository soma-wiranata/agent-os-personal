---
source: hono
category: middleware
---
# App Factory Split

Define two factory functions in `src/lib/create-app.ts`. Never call `new Hono()` directly in route files.

```typescript
// lib/create-app.ts
export function createRouter() {
  return new Hono<AppBindings>({ strict: false })
}

export default function createApp() {
  const app = createRouter()
  app.use('/api/auth/*', authCors)  // scoped CORS
  app.use('*', withSession)          // global session
  app.use(requestId())
  app.notFound(notFound)
  app.onError(onError)
  return app
}
```

- `createApp()`: registers ALL global middleware and error handlers — called once in `app.ts`
- `createRouter()`: returns a bare typed Hono instance — used in every route file
- `AppBindings` type and `strict: false` are defined once in `createRouter()`, propagated everywhere automatically
