---
source: hono
category: testing
---
# Test Data Isolation

Use `beforeEach` hooks to insert test-specific mock records rather than sharing a single dataset via `beforeAll`.

```typescript
import { beforeEach, test } from 'vitest';
import { userFactory } from '@repo/db/factories';

let testUser;

beforeEach(async () => {
  testUser = await userFactory();
});

test('mutates data safely', async () => {
  // Safe isolated test case
});
```

- Bypasses shared state leakage by recreating required database rows before every individual test block.
- Blocks database mutations in one test from silently corrupting or breaking expectations in later tests.
- Facilitates safe test concurrency and arbitrary test execution orders without side-effect issues.
