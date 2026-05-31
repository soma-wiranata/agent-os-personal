---
source: shared
category: api
---
# Pagination Remix Consumption

Extract pagination search parameters directly from the URL query string in loaders, and use `useFetcher.load()` for UI pagination updates.

```typescript
// app/modules/items/route-list.tsx
export async function loader({ request }: Route.LoaderArgs) {
  const url = new URL(request.url);
  const cursor = url.searchParams.get('cursor') ?? undefined;
  const limit = url.searchParams.get('limit') ?? '20';
  
  const data = await getItems({ cursor, limit });
  return { data };
}
```

- Integrates query parameters with standard loader operations using native `URL` and `searchParams` APIs.
- Employs `useFetcher.load()` to fetch additional rows asynchronously, keeping the active scroll position stable.
- Eliminates standard navigation redirects or URL history bloat during simple infinite feed expansions.
