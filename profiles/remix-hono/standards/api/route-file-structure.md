---
source: hono
category: api
---
# Route File Structure

Separate OpenAPI route definitions from business logic handlers across three files per resource.

| File | Purpose |
|---|---|
| `*.routes.ts` | OpenAPI route definition, request/response schemas, tags |
| `*.handlers.ts` | Business logic, uses `AppRouteHandler<T>` type |
| `*.index.ts` | Binds routes to handlers via `createRouter().openapi()` |

- **Exception:** Single simple endpoints may be grouped into one file if three files is overkill
- Route handlers must use `AppRouteHandler<RouteType>` — never untyped async functions
