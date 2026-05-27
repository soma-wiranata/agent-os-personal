---
source: hono
category: cloudflare
---
# Typed Environment Bindings

Always instantiate Hono apps with typed `Bindings` and `Variables` generics when deploying to Cloudflare Workers.

```typescript
type Env = { BOT_TOKEN: string; DB: D1Database; KV: KVNamespace }

const app = new Hono<{ Bindings: Env; Variables: { user: User | null } }>()
```

- Maintain a single central `types.ts` exporting `Bindings` and `Variables`
- Eliminates `c.env.MISSING_VAR` runtime failures through TypeScript enforcement
- Never access `process.env` directly — Cloudflare Workers bindings are only available on `c.env`
