---
source: hono
category: api
---
# Standardized HTTP Status Codes

Always use `stoker/http-status-codes` for status codes — never raw integer literals.

```typescript
import * as HttpStatusCodes from 'stoker/http-status-codes'
return c.json(data, HttpStatusCodes.OK)   // ✓
return c.json(data, 200)                   // ✗
```

- Prevents magic numbers and eliminates typos in status codes
