---
source: hono
category: testing
---
# Database Test Environment

Use `drizzle-kit push` to set up the test database in `beforeAll` and `fs.rmSync` to tear it down in `afterAll`.

```typescript
import { execSync } from 'node:child_process'
import fs from 'node:fs'

beforeAll(async () => { execSync('pnpm drizzle-kit push') })
afterAll(async () => { fs.rmSync('test.db', { force: true }) })
```

- Running against a real SQLite DB catches DB-level errors that mocks cannot
- **Critical:** Tests must run serially (not in parallel) to prevent race conditions on the shared `test.db` file
