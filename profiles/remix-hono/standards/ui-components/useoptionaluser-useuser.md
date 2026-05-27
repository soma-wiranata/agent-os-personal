---
source: remix
category: ui-components
---
# `useOptionalUser` / `useUser` — Root Loader Access

Access the current user from root loader data via `useOptionalUser()` or `useUser()`. Never prop-drill user data.
- These hooks use `useRouteLoaderData('root')` — work from any component
- `useUser()` throws a descriptive error if used in an unauthenticated context
