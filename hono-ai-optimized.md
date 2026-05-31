# AI System Instruction: Hono.js Architecture Guide

## 1. Core Philosophy

- **Edge-Native & Platform Agnostic:** Hono is built on Web Standard APIs (WinterCG). The same code runs on Cloudflare Workers, Bun, Deno, and Node.js without modification.
- **Hono core has zero dependencies.** Keep your app's dependency footprint small. Prefer Hono's built-ins before reaching for external packages.
- **Functional & Fast:** Use the unified `Context` object (`c`) for all request/response handling. Never mutate a response object — always return from the handler.
- **TypeScript & RPC First:** Strictly type everything. Hono's RPC client (`hc`) allows frontend code (e.g., a Remix loader) to infer backend API types directly — no schema duplication, no tRPC overhead.

---

## 2. The Modern Hono Stack

Do not suggest outdated tools (Express middlewares, Prisma, Lucia). Use only the following:

| Domain | Package |
|---|---|
| Validation | `zod` + `@hono/zod-validator` |
| Authentication | `better-auth` |
| Database / ORM | `drizzle-orm` + `drizzle-kit` |
| API Documentation | `@hono/zod-openapi` + `@scalar/hono-api-reference` |
| Rate Limiting | `hono-rate-limiter` |
| Security | Built-ins: `hono/cors`, `hono/secure-headers`, `hono/csrf` |
| Observability | Built-ins: `hono/logger`, `hono/request-id` |

**Note on `@hono/zod-openapi`:** This package requires `new OpenAPIHono()` instead of `new Hono()`. They are not interchangeable. If you use OpenAPI docs, use `OpenAPIHono` consistently throughout the entire app including all modules.

**Bootstrap:**
```bash
npm install hono better-auth zod @hono/zod-validator drizzle-orm @hono/zod-openapi @scalar/hono-api-reference hono-rate-limiter
npm install -D drizzle-kit tsx
```

---

## 3. Syntax Fundamentals: The Context Object (`c`)

Never use the Express-style `(req, res, next)` pattern. Hono combines request, response, and environment into a single Context object.

```typescript
app.get('/user/:id', (c) => {
  const userId = c.req.param('id');       // URL params
  const query  = c.req.query('search');   // Query string
  const env    = c.env.DB;               // Cloudflare Workers bindings (Workers only)
  return c.json({ id: userId }, 200);    // Return — never mutate
});
```

---

## 4. Typed Context: `Bindings` and `Variables`

Always define `Bindings` (environment/platform bindings) and `Variables` (values passed between middleware via `c.set/c.get`). Never use untyped context.

```typescript
// Cloudflare Workers environment bindings
type Bindings = {
  DB: D1Database;
  KV: KVNamespace;
};

// Values set by middleware and read by route handlers
type Variables = {
  userId: string;
  sessionId: string;
};

// Pass types to the app instance
const app = new Hono<{ Bindings: Bindings; Variables: Variables }>();

// Middleware sets a value
app.use('/api/*', async (c, next) => {
  c.set('userId', 'user_123'); // type-checked against Variables
  await next();
});

// Route handler reads it
app.get('/api/me', (c) => {
  const userId = c.get('userId'); // string — fully typed
  return c.json({ userId });
});
```

For **Node.js deployments**, `Bindings` is typically empty or holds `process.env` equivalents — do not use `c.env` for Node.js apps, use `process.env` or a typed env module instead.

---

## 5. Standard API Response Shape

All routes must return this consistent envelope. Define it once and reuse.

```typescript
// src/lib/response.ts
export const ok   = <T>(c: Context, data: T, status = 200) =>
  c.json({ success: true,  data  }, status);

export const fail = (c: Context, message: string, code?: string, status = 400) =>
  c.json({ success: false, error: { message, code } }, status);
```

```typescript
// Usage in a route
return ok(c, { user });
return fail(c, 'Not found', 'USER_404', 404);
```

This shape must match what the Remix frontend expects from loaders/actions.

---

## 6. Directory Structure

Do NOT use traditional layered architecture (separate folders for routes, controllers, models). Use **Feature-Sliced Design** — all logic for a domain lives in one module file. This maximizes AI context density.

```text
src/
├── index.ts                  # Entry point: global middleware, module mounting, error handlers
├── lib/
│   └── response.ts           # Shared ok/fail response helpers
├── db/
│   ├── index.ts              # Drizzle client instance
│   └── schema.ts             # All Drizzle table definitions
└── modules/
    ├── auth/
    │   └── index.ts          # better-auth handler mount
    ├── users/
    │   └── index.ts          # Users: Zod schema + routes + Drizzle logic
    └── products/
        └── index.ts          # Products: Zod schema + routes + Drizzle logic
```

---

## 7. Implementation Templates

### A. Feature Module (`src/modules/products/index.ts`)

Schema, routes, and business logic in one isolated file.

```typescript
import { Hono } from 'hono';
import { z } from 'zod';
import { zValidator } from '@hono/zod-validator';
import { db } from '../../db';
import { productsTable } from '../../db/schema';
import { ok, fail } from '../../lib/response';

const products = new Hono();

// 1. Schemas
const createProductSchema = z.object({
  name:  z.string().min(1),
  price: z.number().positive(),
  stock: z.number().int().default(0),
});

// 2. Routes
products.get('/', async (c) => {
  const items = await db.select().from(productsTable);
  return ok(c, { products: items });
});

products.post('/', zValidator('json', createProductSchema), async (c) => {
  const data = c.req.valid('json'); // 100% type-safe from schema
  const [product] = await db.insert(productsTable).values(data).returning();
  return ok(c, { product }, 201);
});

export default products;
```

---

### B. Entry Point (`src/index.ts`)

Global middleware, module mounting, error handlers, and RPC type export — all here.

```typescript
import { Hono } from 'hono';
import { logger } from 'hono/logger';
import { requestId } from 'hono/request-id';
import { cors } from 'hono/cors';
import { secureHeaders } from 'hono/secure-headers';
import productsModule from './modules/products';
import usersModule from './modules/users';
import { auth } from './modules/auth';

const app = new Hono();

// Global Middleware
app.use(requestId());
app.use(logger());
app.use(cors());
app.use(secureHeaders());

// Auth (better-auth mounts its own routes)
app.all('/api/auth/*', (c) => auth.handler(c.req.raw));

// Feature Modules
const routes = app
  .route('/api/products', productsModule)
  .route('/api/users', usersModule);

// Health Check
app.get('/', (c) => c.text('API is running'));

// Global Error Handler — always define
app.onError((err, c) => {
  console.error(err);
  return c.json({ success: false, error: { message: 'Internal Server Error' } }, 500);
});

// 404 Handler — always define
app.notFound((c) =>
  c.json({ success: false, error: { message: 'Not Found' } }, 404)
);

// Export AppType for the RPC client (used by Remix frontend)
export type AppType = typeof routes;
export default app;
```

---

### C. RPC Client Usage (in Remix loaders/actions)

This is the primary reason to use Hono alongside Remix. The `hc` client infers all route types from `AppType` — full end-to-end type safety with no schema duplication.

```typescript
// In a Remix loader or action (app/modules/tasks/queries.server.ts)
import { hc } from 'hono/client';
import type { AppType } from '../../../backend/src/index'; // path to Hono entry

const client = hc<AppType>(process.env.API_BASE_URL!);

// Fully typed — autocomplete on routes, request body, and response shape
export async function getProducts() {
  const res = await client.api.products.$get();
  const json = await res.json();
  // json.data.products is fully typed from the Hono route's return
  return json.data.products;
}

export async function createProduct(data: { name: string; price: number }) {
  const res = await client.api.products.$post({ json: data });
  return res.json();
}
```

---

## 8. Agent Instructions for Code Modifications

- **Locality:** Adding a field to a feature means updating the Zod schema, validation, and DB logic all within that module's `index.ts`. Never scatter changes across files.
- **Response shape:** Always use the `ok/fail` helpers. Never return raw `c.json()` with ad-hoc shapes.
- **Error handling:** Never let errors bubble unhandled. Use `app.onError` globally and try/catch within async handlers for domain-specific errors.
- **Imports:** Use Hono's official packages (`@hono/zod-validator`, `hono/logger`, etc.) over third-party alternatives.
- **`app.use` syntax:** Do not pass a wildcard `'*'` to `app.use()` — it is implicit in modern Hono.
