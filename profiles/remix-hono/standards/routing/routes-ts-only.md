---
source: remix
category: routing
---
# Routes TS Only

Declare all application routes explicitly in the central `app/routes.ts` file instead of inferring them from filenames or filesystem-based naming conventions.

```typescript
// app/routes.ts
import { type RouteConfig, route, index } from "@react-router/dev/routes";

export default [
  index("modules/home/route-home.tsx"),
  route("tasks", "modules/tasks/route-list.tsx"),
  route("tasks/:id", "modules/tasks/route-detail.tsx"),
] satisfies RouteConfig;
```

- Obsoletes complicated and brittle filename-based conventions (dots, dollar signs, underscores) from earlier Remix versions.
- Establishes a single, central source of truth for the entire application's route structure and mapping.
- Decouples physical file location from URL structures, enabling complete freedom in feature directory co-location.
