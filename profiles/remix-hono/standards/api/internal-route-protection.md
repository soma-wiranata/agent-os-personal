---
source: hono
category: api
---
# Internal Route Protection

Protect internal cron/webhook endpoints with Basic Token auth against a shared secret.

```typescript
const auth = c.req.header('Authorization')
if (auth !== `Basic ${env().CRON_SECRET}`) return c.text('Unauthorized', 401)
```

- Internal routes don't need OpenAPI docs — use standard `Hono` (not `OpenAPIHono`) and validate payloads with `schema.safeParse()`
- Return `422 Unprocessable Entity` on failed validation, `401 Unauthorized` on auth failures
