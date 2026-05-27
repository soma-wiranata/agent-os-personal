---
source: remix
category: middleware
---
# Context Storage Middleware — First in Array

Use `createContextStorageMiddleware` to access `context`/`request` in deeply nested helpers without prop-drilling.
- **Must be the first middleware in the array** — every other middleware that uses `getContext()` depends on it
- Only call `getContext()` / `getRequest()` inside a middleware chain — never at module init time
- Throws a descriptive error if called outside middleware scope — never catch and swallow it
