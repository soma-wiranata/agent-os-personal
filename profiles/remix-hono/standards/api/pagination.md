---
source: shared
category: api
---
# Cursor-Based Pagination

Use cursor-based pagination for all public-facing resource feeds. Use offset/page-based pagination only for internal admin tables where users jump to arbitrary pages.

---

### Standard Query Schema

Define a shared `paginationQuerySchema` in `packages/db` and reuse it across all paginated Hono routes.

```typescript
export const paginationQuerySchema = z.object({
  cursor: z.string().optional(),
  limit:  z.coerce.number().int().min(1).max(100).default(20),
})
```

- `cursor` is an opaque base64 string encoding composite sort fields (e.g. `id:createdAt`) — never a raw ID
- Always validate via `zValidator('query', paginationQuerySchema)` — never read `c.req.query()` directly for pagination params

---

### Standard Response Shape

All paginated responses must follow this shape inside the API envelope:

```typescript
{
  success: true,
  data: {
    items:      T[],
    nextCursor: string | null,  // null = last page
    hasMore:    boolean,
  }
}
```

---

### The `limit + 1` Query Pattern

Always fetch one extra record to determine `hasMore` without a separate `COUNT` query.

```typescript
const rows = await db.select().from(table).limit(limit + 1)
const hasMore    = rows.length > limit
const items      = hasMore ? rows.slice(0, limit) : rows
const nextCursor = hasMore ? encodeCursor(items.at(-1)) : null
```

- Always decode and validate the incoming cursor server-side before converting to DB filters — never trust raw client cursor values
- Never use a `COUNT(*)` query to compute `hasMore` — it's a full table scan

---

### Consuming Pagination in Remix

Read `cursor` and `limit` from `searchParams` in loaders and pass them to the RPC client.

```typescript
const url    = new URL(request.url)
const cursor = url.searchParams.get('cursor') ?? undefined
const limit  = url.searchParams.get('limit')  ?? '20'
const json   = await getItems({ cursor, limit })
```

For "load more" / infinite scroll UI, use `useFetcher` with `.load()` — never trigger full-page navigation for appending items.
