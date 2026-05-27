---
source: hono
category: api
---
# Typed App Instantiation

Always instantiate Hono apps and sub-routers with explicit `Bindings` and `Variables` generic types. Never use a raw `new Hono()`.

```typescript
// Define once in types.ts
const app = new Hono<{ Bindings: Bindings; Variables: Variables }>()

// For sub-routers, always use createRouter() (never new Hono() directly)
import { createRouter } from '@/lib/create-app'
const router = createRouter()
```

- Maintain a central `types.ts` exporting `Bindings` (env vars, KV, D1) and `Variables` (request-scoped context like `user`, `db`, `session`)
- Prevents `c.env.MISSING_VAR` runtime failures through TypeScript enforcement
