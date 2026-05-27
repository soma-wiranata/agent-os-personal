---
source: hono
category: api
---
# API Response Envelope

All public-facing API responses must follow a consistent `success / error` envelope.

```json
// Success
{ "success": true, "message": "...", "data": {} }

// Error
{ "success": false, "error": "NOT_FOUND", "message": "...", "details": {} }
```

- Clients always check `success` first before parsing the payload
- Error codes must be uppercase strings (e.g. `INTERNAL_ERROR`, `VALIDATION_ERROR`, `NOT_FOUND`)
- Use a `result.success()` / `result.error()` utility wrapper — never return raw JSON objects
