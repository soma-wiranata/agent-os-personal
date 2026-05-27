---
source: remix
category: error-handling
---
# Filter Noise from `handleError`

In `entry.server.tsx`, silently ignore aborted requests and 404s before reporting to error tracking.
- Aborted requests = user navigated away — always safe to ignore
- 404s are usually bot scanners — log locally if needed but do not alert

```ts
export const handleError: HandleErrorFunction = (error, { request }) => {
  if (request.signal.aborted) return
  if (isRouteErrorResponse(error) && error.status === 404) return
  Sentry.captureException(error)
}
```
