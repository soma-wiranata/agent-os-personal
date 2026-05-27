---
source: remix
category: routing
---
# Type-Safe Link Generation via `href()`

Never construct routing URLs manually via string interpolation when they contain parameters.
- Import `href` from `react-router` to validate path and parameter existence at compile time

```ts
<Link to={href('/:locale?/products/:handle', { handle: 'my-product' })}>...</Link>
return redirect(href('/:locale?/subscribe'))
```
