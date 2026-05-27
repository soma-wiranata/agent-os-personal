---
source: hono
category: api
---
# OpenAPI Route Definitions

Define all public API routes using `@hono/zod-openapi`'s `createRoute()` — not standard `app.get()`.

```typescript
const getRoute = createRoute({
  method: 'get',
  path: '/{id}',
  request: { params: ParamsSchema },
  responses: {
    200: { content: { 'application/json': { schema: MonitorSchema } }, description: 'The monitor' },
    ...openApiErrorResponses,
  },
})
```

- Provides runtime request/response validation and auto-generates Swagger/Scalar documentation
- Use `defaultHook: handleZodError` on routers for standardized validation failure responses
- Internal routes (webhooks, cron handlers) may use standard Hono routing — `createRoute` preferred for consistency
