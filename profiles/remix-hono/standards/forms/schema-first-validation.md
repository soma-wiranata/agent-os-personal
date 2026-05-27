---
source: remix
category: forms
---
# Schema-First Validation — Conform + Zod

Define a Zod schema at the route level. Use `parseWithZod` in the action and `getZodConstraint` in the form hook. Never validate form data manually.
- Use `hideFields: ['password']` in `submission.reply()` to strip sensitive fields from the response
- For async validation (DB checks), use `schema: (intent) => Schema.transform(...)` — skip async work when `intent !== null`
- Always return `{ result: submission.reply() }` on failure so the form restores state
