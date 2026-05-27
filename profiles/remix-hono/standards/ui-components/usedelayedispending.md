---
source: remix
category: ui-components
---
# `useDelayedIsPending` — Avoid Loading State Flash

Use `useDelayedIsPending` with `delay: 400` and `minDuration: 300` instead of raw `navigation.state`.
- Prevents a flash of loading UI for sub-400ms responses
- Use `StatusButton` with `status={isPending ? 'pending' : form.status ?? 'idle'}`
