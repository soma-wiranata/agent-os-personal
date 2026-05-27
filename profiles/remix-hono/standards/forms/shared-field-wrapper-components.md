---
source: remix
category: forms
---
# Shared Field Wrapper Components

Never render raw inputs. Always use shared field wrappers that auto-generate `id`, wire `aria-invalid` + `aria-describedby`, and render `<ErrorList>`.
- `CheckboxField` uses `useInputControl` from `@conform-to/react` to bridge Radix state with Conform
- `ErrorList` accepts `Array<string | null | undefined> | null | undefined` — pass `fields.x.errors` directly
