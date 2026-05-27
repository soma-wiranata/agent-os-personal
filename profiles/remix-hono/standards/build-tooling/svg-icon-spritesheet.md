---
source: remix
category: build-tooling
---
# SVG Icon Spritesheet — Never Import Raw SVGs

Compile all icons into a single SVG sprite via `vite-plugin-icons-spritesheet`. Never import SVGs directly.
- Source icons in `app/assets/icons/` (or `other/svg-icons/`) — one HTTP request regardless of icon count
- Icon names are typed — TypeScript errors on unknown icon names
- Preload the sprite in `root.tsx` with `fetchPriority="high"` via a hidden `<img>` for LCP optimization

```tsx
<Icon name="check" />
// root.tsx: <img src={iconsHref} alt="" hidden fetchPriority="high" />
```
