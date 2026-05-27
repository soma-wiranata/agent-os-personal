---
source: remix
category: forms
---
# Use `namedAction` for Multi-Intent Routes

Use `namedAction` when a route handles multiple form submissions. The intent field name is always `intent`.
- Always define a `default` handler to avoid unhandled `ReferenceError`s
- Works with `FormData` only — not URL search params
- Do not use for separate resource routes — only when multiple forms share one route

```ts
export async function action({ request }: Route.ActionArgs) {
  return namedAction(await request.formData(), {
    async create() { return redirect('/items') },
    async delete() { return redirect('/items') },
    async default() { throw new Response('Unknown action', { status: 400 }) },
  })
}
```
