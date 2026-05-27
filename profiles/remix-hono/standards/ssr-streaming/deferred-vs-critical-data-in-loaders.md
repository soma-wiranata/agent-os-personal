---
source: remix
category: ssr-streaming
---
# Deferred vs. Critical Data in Loaders

Start non-blocking queries immediately; only `await` above-the-fold data.
- Pass non-blocking promises directly to `data()` — resolve client-side via `Suspense`
- Awaiting everything blocks TTFB unnecessarily

```ts
const deferredData = loadDeferredData(context)          // starts, not awaited
const criticalData = await loadCriticalData(context)    // blocks until ready
return data({ ...criticalData, ...deferredData })
```
