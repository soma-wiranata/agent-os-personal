---
source: hono
category: api
---
# Feature-Sliced Module

Group all logic for a domain (schema, routes, and database queries) inside a single `src/modules/[feature]/index.ts` file instead of splitting them across separate routing, controller, and database layers.

```typescript
// src/modules/products/index.ts
import { Hono } from 'hono';
import { z } from 'zod';
import { zValidator } from '@hono/zod-validator';
import { db } from '../../db';
import { productsTable } from '../../db/schema';
import { ok } from '../../lib/response';

const products = new Hono();

const createProductSchema = z.object({
  name: z.string().min(1),
  price: z.number().positive(),
});

products.get('/', async (c) => {
  const items = await db.select().from(productsTable);
  return ok(c, { products: items });
});

products.post('/', zValidator('json', createProductSchema), async (c) => {
  const data = c.req.valid('json');
  const [product] = await db.insert(productsTable).values(data).returning();
  return ok(c, { product }, 201);
});

export default products;
```

- Maximizes AI context density by keeping all domain operations colocated.
- Enforces the locality rule to ensure any changes to a feature are entirely self-contained.
- OpenAPI routes utilizing complex schemas are the only exception and use a three-file split structure.
