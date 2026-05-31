---
source: shared
category: build-tooling
---
# Shared Package Boundaries

Never import code directly from `apps/*` across application boundaries; all shared business code and types must live inside `packages/*`.

```typescript
// Good: Import shared abstractions from packages
import { db } from '@repo/db';
import type { AppType } from '@repo/types';

// Bad: Cross-importing directly from another app
import type { AppType } from '../../apps/api/src/index';
```

- Enforces clean circular-dependency-free boundaries by preventing direct cross-application imports.
- `packages/db` acts as the single database access point, exporting schema types and client instances.
- `packages/types` re-exports backend contracts like Hono `AppType` to keep frontend packages decoupled.
