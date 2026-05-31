---
source: hono
category: security
---
# CORS Server to Server Exemption

Exclude server-to-server routes under `/internal/*` and `/webhooks/*` from any CORS middleware execution paths.

```typescript
import { Hono } from 'hono';
import { apiCors } from './cors';

const app = new Hono();

// Apply CORS only to client-facing endpoints, exempting internal paths
app.use('/api/*', apiCors);
```

- Bypasses browser-specific CORS requirements since non-browser integrations never transmit browser Origin headers.
- Employs secure pre-shared header keys or IP validation lists rather than CORS rules for server-to-server authorization.
- Eliminates overhead and execution logs of useless preflight request processing on internal worker paths.
