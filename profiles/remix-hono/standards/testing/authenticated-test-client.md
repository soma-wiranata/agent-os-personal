---
source: hono
category: testing
---
# Authenticated Test Client

Use a `createAuthenticatedClient(user)` test helper that records a real session in the database and returns a client with valid request headers.

```typescript
import { testClient } from 'hono/testing';
import { createTestApp } from '@/lib/create-app';
import { sessionFactory } from '@repo/db/factories';
import router from '../index';

export async function createAuthenticatedClient(user: User) {
  const session = await sessionFactory({ userId: user.id });
  return testClient(createTestApp(router), {
    headers: { Cookie: `session=${session.id}` },
  });
}
```

- Bypasses auth middleware mocks to ensure the test environment exercises genuine token resolution code.
- Registers a physical session row to test full database auth queries.
- Pre-sets cookies inside client headers to keep integration tests clean of cookie manipulation boilerplate.
