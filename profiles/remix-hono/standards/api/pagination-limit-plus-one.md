---
source: shared
category: api
---
# Pagination Limit Plus One

Always fetch `limit + 1` records from the database to determine `hasMore` status without executing a separate count query.

```typescript
const rows = await db.select().from(table).limit(limit + 1);
const hasMore = rows.length > limit;
const items = hasMore ? rows.slice(0, limit) : rows;
const nextCursor = hasMore ? encodeCursor(items.at(-1)) : null;
```

- Bypasses expensive `COUNT(*)` database queries that trigger full table scans under load.
- Truncates the result set gracefully to the exact requested limit before returning data to the client.
- Decodes and validates the incoming cursor strictly on the server rather than trusting raw client inputs.
