---
source: hono
category: api
---
# OpenAPIHono Consistency

Always use `new OpenAPIHono()` consistently across all modules and sub-routers if the application uses `@hono/zod-openapi` instead of mixing standard `Hono` and `OpenAPIHono` instances.

```typescript
import { OpenAPIHono } from '@hono/zod-openapi';

// Good: Consistent usage
const app = new OpenAPIHono();
const products = new OpenAPIHono();
app.route('/products', products);

// Bad: Mixed instances
import { Hono } from 'hono';
const mainApp = new OpenAPIHono();
const subRouter = new Hono(); // Mix breaks OpenAPI route registration
```

- Standard Hono and OpenAPIHono routes are not fully interchangeable and mixing them silently breaks route registration.
- Guarantees complete and accurate OpenAPI documentation schema generation without missing endpoints.
- Avoids compiler and type-safety issues across nested route modules.
