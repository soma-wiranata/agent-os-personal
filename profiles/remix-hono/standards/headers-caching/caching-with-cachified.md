---
source: remix
category: headers-caching
---
# Caching with `cachified` — Always Use the Local Wrapper

Never import from `@epic-web/cachified` directly — use the re-exported `cachified` from `cache.server.ts`.
- The local wrapper automatically integrates Server-Timing headers for cache miss/hit profiling in DevTools
- Supports `forceFresh` via `?fresh` URL param for admin cache-busting
- Two layers: `lruCache` (in-memory, fast, resets on restart) and `cache` (SQLite, survives deploys)
- Cache keys must be globally unique — prefix with entity type: `user-${id}`, `note-${id}`
