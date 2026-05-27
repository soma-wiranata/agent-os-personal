---
source: hono
category: testing
---
# OpenAPI Contract Validation

Always assert the response status code before calling `response.json()` to leverage TypeScript type narrowing.

```typescript
const response = await client.tasks.$post({ json: { name: '' } })
expect(response.status).toBe(422)

if (response.status === 422) {
  const json = await response.json()
  expect(json.error.issues[0].message).toBe(ZOD_ERROR_MESSAGES.EXPECTED_STRING)
}
```

- `hono/testing` returns a union of all possible OpenAPI response shapes
- The `if (response.status === X)` check narrows the TypeScript type of `response.json()` automatically
- This provides strict end-to-end type safety for both success and error response shapes
