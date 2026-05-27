---
source: hono
category: api
---
# Empty PATCH Validation

Manually validate that PATCH request bodies are not empty objects before processing.

```typescript
const updates = c.req.valid('json')
if (Object.keys(updates).length === 0) {
  return c.json({ success: false, error: { issues: [{ code: ZOD_ERROR_CODES.INVALID_UPDATES, ... }], name: 'ZodError' } }, HttpStatusCodes.UNPROCESSABLE_ENTITY)
}
```

- Zod allows empty objects for partial schemas — this check must be manual
- Always use `ZOD_ERROR_CODES` / `ZOD_ERROR_MESSAGES` constants for consistency across PATCH routes
