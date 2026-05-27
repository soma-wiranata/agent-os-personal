---
source: hono
category: middleware
---
# Environment-Aware Error Handling

Trust the universal error handler (`app.onError`) to sanitize errors for production. Throw rich errors; sanitize nothing manually.

- **Production**: strips stack traces, replaces internal messages with generic `"An unexpected error occurred"`
- **Development**: exposes full stack traces, `details` payload from `ZodError` or custom errors
- Always throw `LibraError` (or equivalent custom error) with rich `details` — the handler will do the right thing per environment
