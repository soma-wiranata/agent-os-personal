---
source: hono
category: testing
---
# Testing Framework & Client

Always use `Vitest` and `hono/testing`'s `testClient` for API tests. No exceptions.

```typescript
import { testClient } from 'hono/testing'
import { describe, expect, it } from 'vitest'
import router from './tasks.index'

const client = testClient(createTestApp(router))
const response = await client.tasks.$post({ json: { name: 'Test' } })
```

- `testClient` provides end-to-end type safety and autocomplete derived from OpenAPI route definitions
- `Jest` and `Supertest` are strictly forbidden
