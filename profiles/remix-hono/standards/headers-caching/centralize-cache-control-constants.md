---
source: remix
category: headers-caching
---
# Centralize Cache-Control Constants

Define `Cache-Control` values as named constants in a shared module (e.g., `app/http.ts`). Never hardcode cache strings in route headers exports.

```ts
export const CACHE_CONTROL = {
  doc: 'public, max-age=300, stale-while-revalidate=604800',
  none: 'no-store, no-cache, must-revalidate, max-age=0',
}
```
