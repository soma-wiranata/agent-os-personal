---
source: remix
category: ssr-streaming
---
# Wrap `hydrateRoot` in `startTransition`

Always wrap `hydrateRoot` in `startTransition` to defer hydration as a non-urgent update.
- Hydrate `document` (full document), not a specific DOM element
- Always wrap `<RemixBrowser />` in `<StrictMode>`
