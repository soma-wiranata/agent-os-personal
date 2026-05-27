---
source: remix
category: ui-components
---
# `cn()` — All Conditional Class Names

Use `cn()` (= `clsx` + `tailwind-merge`) for all conditional class strings. Never concatenate manually.
- Later classes override earlier ones: `cn('p-4', 'p-2')` → `'p-2'`
