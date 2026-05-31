---
source: hono
category: testing
---
# Test Factory Functions

Define one factory utility function per database table inside `packages/db/src/factories.ts` to safely generate type-safe mock data records.

```typescript
import { createId } from '@paralleldrive/cuid2';
import { db } from '../index';
import { users } from '../schema';
import type { UserInsert } from '../schema';

export const userFactory = async (overrides: Partial<UserInsert> = {}) => {
  const [user] = await db.insert(users).values({
    id: createId(),
    email: `test-${createId()}@example.com`,
    ...overrides,
  }).returning();
  return user;
};
```

- Types the overrides parameter using the schema's `$inferInsert` type mapping.
- Includes a `.returning()` clause on inserts to return the database row containing generated primary key IDs.
- Uses dynamic strings (e.g. `createId()`) for unique column defaults to prevent unique constraint failures when tests loop.
