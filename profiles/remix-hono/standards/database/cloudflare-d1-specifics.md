---
source: hono
category: database
---
# Cloudflare D1 Specifics

When using Cloudflare D1 (SQLite Workers), use `DB.batch()` for multi-statement atomic operations.

```typescript
const [folderResult, pageResult] = await DB.batch([
  DB.prepare(`UPDATE folders SET isDeleted = 1 WHERE id = ?`).bind(id),
  DB.prepare(`UPDATE pages SET isDeleted = 1 WHERE folderId = ?`).bind(id),
])
```

- D1 does not support `BEGIN TRANSACTION / COMMIT` via the client API — `DB.batch()` is the correct alternative
- Always use `.bind()` to parameterize queries; always type result sets with generics: `.all<Folder>()`
