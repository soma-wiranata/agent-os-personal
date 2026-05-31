---
source: hono
category: api
---
# API Response Envelope

All public-facing API responses must follow a consistent `success / error` envelope.

```typescript
// Success
{ "success": true, "data": {} }

// Error
{ "success": false, "error": { "message": "...", "code": "NOT_FOUND" } }
```

- Clients always check `success` first before parsing the payload.
- Error codes must be uppercase strings (e.g. `INTERNAL_ERROR`, `VALIDATION_ERROR`, `NOT_FOUND`).
- Use the `ok(c, data)` and `fail(c, message, code)` helpers from `src/lib/response.ts` — never return raw JSON objects.
