---
source: remix
category: ui-components
---
# `useGlobalPendingState` — Global Spinner

Use `useGlobalPendingState` in root layout for global loading indicators — not `useNavigation()` alone.
- `useNavigation()` only tracks browser navigations; fetcher submissions are invisible to it
- Place global indicators in `root.tsx` or a shared layout — not per-route
