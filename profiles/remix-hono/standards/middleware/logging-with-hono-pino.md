---
source: hono
category: middleware
---
# Logging with hono-pino

Always use `hono-pino` for structured logging. `console.log` is strictly forbidden in production code.

```typescript
c.var.logger.info('Processing task', { taskId })   // ✓
console.log('Processing task', taskId)              // ✗
```

- `hono-pino` automatically attaches request/response data and outputs structured JSON
- Configure `pino` to read its log level from `LOG_LEVEL` env var — never hardcode a level
- Use `pino-pretty` in development only — production must output raw JSON (required by log aggregation platforms)
- Temporary `console.log` for local debugging must be removed before committing
