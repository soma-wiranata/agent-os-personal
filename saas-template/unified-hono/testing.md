# Testing Standards

## Rules

---

### Testing Framework & Client

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

---

### App Isolation in Tests

Use `createTestApp(router)` to mount individual routers for testing — never import the global `app`.

```typescript
import { createTestApp } from '@/lib/create-app'
import router from './tasks.index'

const client = testClient(createTestApp(router))
```

- Isolates the router with only the necessary global middlewares
- Prevents unwanted side effects from other routes; keeps tests faster
- Testing the global `app` instance is only necessary for app-level logic (e.g., static file serving)

---

### Database Test Environment

Use `drizzle-kit push` to set up the test database in `beforeAll` and `fs.rmSync` to tear it down in `afterAll`.

```typescript
import { execSync } from 'node:child_process'
import fs from 'node:fs'

beforeAll(async () => { execSync('pnpm drizzle-kit push') })
afterAll(async () => { fs.rmSync('test.db', { force: true }) })
```

- Running against a real SQLite DB catches DB-level errors that mocks cannot
- **Critical:** Tests must run serially (not in parallel) to prevent race conditions on the shared `test.db` file

---

### OpenAPI Contract Validation

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
