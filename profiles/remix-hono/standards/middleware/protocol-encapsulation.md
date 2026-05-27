---
source: hono
category: middleware
---
# Protocol Encapsulation

Never inject raw SDK clients into the context if their use requires writing complex queries. Wrap them in specific typed helper functions first.

```typescript
// In middleware — wrap, don't expose raw client
const fetchUserById: FetchUserById = async (id) => {
  const { data } = await octokit.request('GET /user/{id}', { id })
  return data
}
c.set('fetchUserById', fetchUserById)

// In route handler — clean and protocol-agnostic
const user = await c.var.fetchUserById(userId)
```

- Keeps route handlers clean and protocol-agnostic (REST vs. GraphQL transparent)
- Centralizes error handling, query definitions, and payload mapping in middleware
