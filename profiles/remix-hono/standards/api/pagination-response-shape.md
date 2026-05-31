---
source: shared
category: api
---
# Pagination Response Shape

Format all paginated API success envelopes with a consistent data payload containing `items`, `nextCursor`, and `hasMore` fields.

```typescript
interface PaginatedResponse<T> {
  success: true;
  data: {
    items: T[];
    nextCursor: string | null; // null indicates the last page
    hasMore: boolean;
  };
}
```

- Establishes a contract-level shape that front-end infinite scrolling feeds can consistently consume.
- Declaring `nextCursor` as `null` serves as the explicit end-of-feed marker for clients.
- Prevents mismatched payload conventions across different list resources in the database.
