---
source: remix
category: routing
---
# Always Import Route Types from `./+types/`

Every loader, action, and component imports its types from the auto-generated `+types/` module.
- Never write manual type annotations for loader/action args
- Never use `useLoaderData() as LoaderData` — use `Route.ComponentProps` instead

```ts
import { type Route } from './+types/login.ts'
export async function loader({ request }: Route.LoaderArgs) {}
export default function Page({ loaderData }: Route.ComponentProps) {}
```
