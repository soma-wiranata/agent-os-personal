---
source: remix
category: ssr-streaming
---
# `<ClientOnly>` for Browser-Dependent Components

Wrap browser-only components in `<ClientOnly>` to prevent SSR errors and hydration mismatches.
- Children MUST be a function `{() => <Component />}` — not JSX directly
- Always provide a `fallback` with matching dimensions to prevent CLS
- Do not use `<ClientOnly>` to avoid SSR-compatible code — fix the component if possible
