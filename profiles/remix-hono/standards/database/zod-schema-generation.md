---
source: hono
category: database
---
# Zod Schema Generation

Generate Zod validation schemas from Drizzle schemas using `drizzle-zod`. Never write them by hand.

```typescript
import { createInsertSchema, createSelectSchema } from 'drizzle-zod'
import { toZodV4SchemaTyped } from '@/lib/zod-utils'

export const selectTasksSchema = toZodV4SchemaTyped(createSelectSchema(tasks))
export const insertTasksSchema = toZodV4SchemaTyped(createInsertSchema(tasks))
// @ts-expect-error partial exists on zod v4 type
export const patchTasksSchema = insertTasksSchema.partial()
```

- `toZodV4SchemaTyped` is required to bridge Drizzle-generated schemas with Zod V4's strict type requirements
- Use `.partial()` for PATCH endpoint schemas; the `@ts-expect-error` comment is intentional and required with current Zod V4 types
- Keep validation schemas in a separate `validation.ts` file alongside schema definitions
- Use `z.preprocess()` inside `.extend()` to cast/transform raw DB fields (e.g., JSON strings → arrays)
