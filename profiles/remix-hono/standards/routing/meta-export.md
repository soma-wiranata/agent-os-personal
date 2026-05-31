---
source: remix
category: routing
---
# Meta Export

Always export a `meta` function from every route file to define page titles, descriptions, and SEO metadata.

```typescript
import type { Route } from './+types/route-list';

export const meta: Route.MetaFunction = () => {
  return [
    { title: "My Tasks | Agent OS" },
    { name: "description", content: "View and manage your tasks" }
  ];
};
```

- Search engine crawlers require a unique and accurate document title on the initial server render for correct indexing.
- Prevents every page on a domain from fallback-displaying the same generic root title in browser tabs.
- Merges page-specific metadata arrays cleanly with higher-level layouts during rendering.
