---
source: remix
category: env
---
# Zod-Validated Env at Startup

Declare all environment variables in a Zod schema in `app/utils/env.server.ts`. Call `init()` in `entry.server.tsx` before any other code.
- TypeScript augmentation (`ProcessEnv extends z.infer<typeof schema>`) gives typed `process.env.X` access across all server code
- Only add vars to `getEnv()` if intentionally public — they are embedded in HTML as `window.ENV`
- Optional integrations use `.optional()` in schema — remove `.optional()` when the integration becomes required
- Never access `process.env` directly in app code outside this module

```ts
declare global {
  namespace NodeJS {
    interface ProcessEnv extends z.infer<typeof schema> {}
  }
}
export function init() {
  const parsed = schema.safeParse(process.env)
  if (!parsed.success) throw new Error('Invalid environment variables')
}
```
