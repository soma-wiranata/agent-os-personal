# Middleware Standards

## Rules

---

### App Factory Split

Define two factory functions in `src/lib/create-app.ts`. Never call `new Hono()` directly in route files.

```typescript
// lib/create-app.ts
export function createRouter() {
  return new Hono<AppBindings>({ strict: false })
}

export default function createApp() {
  const app = createRouter()
  app.use('/api/auth/*', authCors)  // scoped CORS
  app.use('*', withSession)          // global session
  app.use(requestId())
  app.notFound(notFound)
  app.onError(onError)
  return app
}
```

- `createApp()`: registers ALL global middleware and error handlers — called once in `app.ts`
- `createRouter()`: returns a bare typed Hono instance — used in every route file
- `AppBindings` type and `strict: false` are defined once in `createRouter()`, propagated everywhere automatically

---

### Typed Middleware Factories

Always use `createMiddleware<Env, Path>` from `hono/factory` for all custom middleware.

```typescript
import { createMiddleware } from 'hono/factory'
import type { HonoEnv } from '../types'

export const dbMiddleware = createMiddleware<HonoEnv, '*'>(async (c, next) => {
  c.set('db', getDbInstance(c.env.DATABASE_URL))
  await next()
})
```

- Provides type safety for `c.env` and `c.var` within the middleware
- Use `'*'` for the path generic if the middleware applies to all routes
- Never write generic `(c, next) => {}` middleware functions

---

### Singleton SDK Initialization

Initialize heavy third-party SDKs (Octokit, DB clients) using a lazy getter at module scope — not inside the middleware handler body.

```typescript
let octokitInstance: Octokit | undefined

function getOctokitInstance(token: string) {
  if (!octokitInstance) octokitInstance = new Octokit({ auth: token })
  return octokitInstance
}

export const githubApiMiddleware = createMiddleware(async (c, next) => {
  const octokit = getOctokitInstance(c.env.GITHUB_API_TOKEN)
  c.set('octokit', octokit)
  await next()
})
```

- In serverless warm-starts, global variables persist between requests on the same worker instance — reuse the heavy client
- Avoids new TCP connections or SDK init overhead on every request
- Always declare the instance variable at module scope; populate it via a `getInstance(credentials)` function

---

### Protocol Encapsulation

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

---

### Logging with hono-pino

Always use `hono-pino` for structured logging. `console.log` is strictly forbidden in production code.

```typescript
c.var.logger.info('Processing task', { taskId })   // ✓
console.log('Processing task', taskId)              // ✗
```

- `hono-pino` automatically attaches request/response data and outputs structured JSON
- Configure `pino` to read its log level from `LOG_LEVEL` env var — never hardcode a level
- Use `pino-pretty` in development only — production must output raw JSON (required by log aggregation platforms)
- Temporary `console.log` for local debugging must be removed before committing

---

### Environment-Aware Error Handling

Trust the universal error handler (`app.onError`) to sanitize errors for production. Throw rich errors; sanitize nothing manually.

- **Production**: strips stack traces, replaces internal messages with generic `"An unexpected error occurred"`
- **Development**: exposes full stack traces, `details` payload from `ZodError` or custom errors
- Always throw `LibraError` (or equivalent custom error) with rich `details` — the handler will do the right thing per environment

---

## Flagged (Score 2 — Review Needed)

- **AsyncLocalStorage (Implicit Context)**: Using `AsyncLocalStorage` to pass request IDs implicitly down the call stack (hono-telescope) is powerful for observability but adds complexity. Only adopt for telemetry/tracing layers — not for general DI.
- **Implicit Self-Hosted Initialization via Middleware** (web-archive): Treating the first incoming bearer token as the admin token is a zero-config onboarding pattern. Only valid for single-user self-hosted applications — never for multi-user or multi-tenant systems.
