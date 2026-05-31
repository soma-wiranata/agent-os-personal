---
source: hono
category: testing
---
# Test Seed vs Factory

Keep database seeds (`seed.ts`) restricted strictly to local developer environments and mock factories strictly to Vitest suite runs.

```typescript
// Predictable stable records for manual developer validation
// packages/db/seed.ts

// Dynamic randomized records for unit/integration vitest blocks
// packages/db/src/factories.ts
```

- Prohibits cross-importing seed lists into tests to avoid hardcoded ID clashes with factory-created keys.
- Prohibits using factories for developer seeds to ensure local environments start with readable, predictable data.
- Keeps test suite data setups decoupled from the initial local development database provisioning.
