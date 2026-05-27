---
source: remix
category: ui-components
---
# Delegated Markdown Links

When rendering HTML from `dangerouslySetInnerHTML`, use a delegation hook to intercept `<a>` clicks and route them through React Router.
- Raw HTML anchors trigger full page reloads — `useDelegatedReactRouterLinks(ref)` converts them to SPA navigations
