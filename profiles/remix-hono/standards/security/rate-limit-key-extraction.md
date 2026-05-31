---
source: hono
category: security
---
# Rate Limit Key Extraction

Determine rate limiting keys based on user session identifiers for authenticated routes and client IP headers for public routes.

```typescript
// Authenticated routes: Limit by account session ID
const authedKey = (c) => c.get('user').id;

// Public routes: Resolve IP, utilizing Cloudflare headers first
const publicKey = (c) =>
  c.req.raw.headers.get('cf-connecting-ip') ??
  c.req.header('x-forwarded-for') ??
  'unknown';
```

- Keys authenticated requests to the current user object to avoid punishing users sharing office network addresses.
- Avoids using generic static fallback values like `|| 'ip'` which groups unrelated traffic into a single rate key.
- Prioritizes edge platform headers (`cf-connecting-ip`) over client-controlled HTTP headers.
