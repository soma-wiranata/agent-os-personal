---
source: hono
category: testing
---
# Testing Fixtures and Factories

Use factory functions and a real-session auth helper to keep tests isolated, typed, and free of hardcoded magic values.

---

### Factory Functions

Define one factory per table in `packages/db/src/factories.ts`. Factories insert via Drizzle and accept a partial override argument.

```typescript
import { createId } from '@paralleldrive/cuid2'
import { db }       from '../index'
import { users }    from '../schema'
import type { UserInsert } from '../schema'

export const userFactory = async (overrides: Partial<UserInsert> = {}) => {
  const [user] = await db.insert(users).values({
    id:    createId(),
    email: `test-${createId()}@example.com`,
    ...overrides,
  }).returning()
  return user
}
```

- Always use `$inferInsert` types for the override parameter — never manually typed
- Always call `.returning()` and return the inserted row — tests need the generated `id`
- Factory defaults must be valid and unique (use `createId()` for emails/slugs) — static defaults cause constraint violations when a test runs twice

---

### Authenticated Test Client

Provide a `createAuthenticatedClient(user)` helper in `src/test/helpers.ts`. It inserts a real session row into the test DB and returns a `testClient` with the session cookie pre-set.

```typescript
import { testClient }   from 'hono/testing'
import { createTestApp } from '@/lib/create-app'
import { sessionFactory } from '@repo/db/factories'
import router from '../index'

export async function createAuthenticatedClient(user: User) {
  const session = await sessionFactory({ userId: user.id })
  return testClient(createTestApp(router), {
    headers: { Cookie: `session=${session.id}` },
  })
}
```

- Always insert a real session row — never mock or stub the auth middleware
- Mocking auth middleware hides bugs in the session resolution path; a real DB session catches them

---

### Test Data Isolation

Use `beforeEach` to seed test-specific data — never `beforeAll`.

- `beforeAll` shares rows across tests in the same file; a mutating test corrupts later tests
- Each test must create its own data via factories and can safely mutate or delete it

---

### Seed Files vs Factories

Seed files (`packages/db/seed.ts`) are for local developer environments only. Factories are for automated tests only.

- Never import seed logic into test files — seed data has named, stable IDs that conflict with factory-generated IDs
- Never use factories in seed files — seeds need human-readable, predictable records; factories produce random ones
