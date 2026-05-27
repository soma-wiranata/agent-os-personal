---
source: remix
category: headers-caching
---
# `pipeHeaders` — Propagate Cache Headers Up the Route Tree

Every route with a loader or action must export `pipeHeaders` as its `headers` function.
- Without `pipeHeaders`, cache headers set in nested routes are silently dropped
- `combineHeaders` uses `append` (preserves duplicate `Set-Cookie`); `mergeHeaders` uses `set` (overwrites)
- Always use `combineHeaders` when setting cookies — using `set` silently drops all but the last cookie

```ts
export const headers: Route.HeadersFunction = pipeHeaders
```
