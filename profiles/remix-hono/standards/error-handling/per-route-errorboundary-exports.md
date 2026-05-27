---
source: remix
category: error-handling
---
# Per-Route `ErrorBoundary` Exports

Every route exports an `ErrorBoundary`. Root exports it as last resort; the `$.tsx` catch-all also uses it.
- A single missing `ErrorBoundary` crashes the whole page on a route error
- Map HTTP status codes (404, 400, 409) to dedicated UI components — do not render generic errors for known codes

```tsx
export function ErrorBoundary() {
  return <GeneralErrorBoundary />
}
```
