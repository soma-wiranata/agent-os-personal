# Unified Remix Stack Standards

> Curated from: `epic-stack`, `kentcdodds.com`, `react-router-website`, `remix-boilerplate`, `remix-store`, `remix-utils`
> Scoring: **3 = Keep** | **2 = Flagged** | **1 = Dropped**

---

## Authentication & Sessions

### DB-Backed Sessions — Cookie Holds ID Only
Store session data in the database. The cookie holds only the `sessionId`. Never store user data directly in the session cookie.
- If the session row is missing or expired, destroy the cookie immediately and redirect to `/`
- `SESSION_SECRET` supports key rotation via comma-separated values: `SECRET1,SECRET2`
- DB expiration is enforced at query time: `expirationDate: { gt: new Date() }`

```ts
export const authSessionStorage = createCookieSessionStorage({
  cookie: { name: 'en_session', sameSite: 'lax', httpOnly: true,
            secrets: process.env.SESSION_SECRET.split(','),
            secure: process.env.NODE_ENV === 'production' }
})
export async function getUserId(request: Request) {
  const sessionId = (await authSessionStorage.getSession(request.headers.get('cookie'))).get(sessionKey)
  if (!sessionId) return null
  const session = await prisma.session.findUnique({
    select: { userId: true },
    where: { id: sessionId, expirationDate: { gt: new Date() } },
  })
  if (!session?.userId) throw redirect('/', { headers: { 'set-cookie': await authSessionStorage.destroySession(...) } })
  return session.userId
}
```

---

### Auth Guards — `requireUserId` and `requireAnonymous`
Use auth guard utilities at the top of every loader and action. Never inline auth logic in routes.
- `requireUserId` preserves current URL as `redirectTo` param unless `{ redirectTo: null }` is passed
- `requireAnonymous` guards login/signup/forgot-password routes — throws if already authenticated
- For role checks, use `requireUserWithPermission` — never `requireUserId` + manual check

---

### Permission Strings — `action:entity:access`
Encode permissions as typed strings in format `action:entity` or `action:entity:access`.
- `own` = the user's own records only; `any` = any record (admin level)
- Check permissions in loaders/actions via `requireUserWithPermission`; on the client via `userHasPermission(user, ...)`
- Never query permissions directly in component code

```ts
type PermissionString = `${Action}:${Entity}` | `${Action}:${Entity}:${Access}`
// Server: await requireUserWithPermission(request, 'read:note:own')
// Client: userHasPermission(user, 'delete:note:any')
```

---

### Split Session Domains
Split session logic into specialized domains — never put everything in one cookie.
- Authentication tracking → `getSession()` (main session)
- Auth UI flash state → `getLoginInfoSession()`
- Anonymous client ID → `getClientSession()`
- Always merge headers from all modified sessions before returning the response

---

### OAuth Providers — Plugin Registration
Register OAuth strategies on the `authenticator` singleton. New providers extend the `providers` map.
- Each provider implements `getAuthStrategy()` — returns `null` to disable itself
- `providerNames` array drives the OAuth button UI — never hardcode provider lists in components
- OAuth callback routes live in `_auth/auth.$provider/`

---

## Security

### CSRF — Header-Based Middleware (Preferred for New Projects)
Use `createCsrfMiddleware` for modern CSRF protection based on `Sec-Fetch-Site`. No tokens needed.
- `same-origin` / `same-site` → always allowed; `cross-site` → blocked by default
- If the app has API/webhook routes that must accept cross-site requests, scope the middleware to a UI layout route, not `root.tsx`
- Never use `allowMissingOrigin: true` unless all clients are verified
- Never use a global-flagged `RegExp` in origin patterns — `.test()` is stateful

```ts
export const [csrfMiddleware] = createCsrfMiddleware();
// app/root.tsx or app/routes/_ui.tsx
export const middleware: Route.MiddlewareFunction[] = [csrfMiddleware];
```

---

### CSRF — Token-Based (Legacy Only)
Use only when `Sec-Fetch-Site` is not reliable. Requires `@oslojs/crypto`.
- Generate and commit token in root loader; provide via `AuthenticityTokenProvider` in root component
- Inject `<AuthenticityTokenInput />` in every form; validate with `csrf.validate(request)` in actions
- Throw 403 on `CSRFError` — never expose internal error codes to the client

<!-- CONFLICT: header-based (csrf-middleware) vs token-based (csrf-token) — prefer header-based for all new projects -->

---

### Honeypot — All Public Forms
Add honeypot hidden fields to every unauthenticated form. Never add to forms behind authentication.
- Set `encryptionSeed` from an env var for consistent encryption across restarts
- `HoneypotProvider` is set up once in `root.tsx` — never add elsewhere
- Throw 400 on `SpamError` — no additional error handling needed

```ts
honeypot.check(formData) // throws SpamError if bot detected
```

---

### Safe Redirects — Always Wrap User-Controlled URLs
Always wrap user-controlled redirect values with `safeRedirect(value, fallback)`.
- Valid: `/dashboard`, `/settings/profile`
- Blocked: `https://evil.com`, `//evil.com`, `/\evil`, `../secret`
- Always provide a meaningful fallback — the default is `/`

```ts
return redirect(safeRedirect(redirectTo, '/dashboard'))
```

---

### Secure Headers — Apply at Root
Apply `createSecureHeadersMiddleware` once at root for global coverage.
- `X-Content-Type-Options: nosniff`, `X-Frame-Options: SAMEORIGIN`, `Strict-Transport-Security`, etc. — all applied by default
- `Cross-Origin-Embedder-Policy` is disabled by default — enables CDN/embed compatibility
- If embedding in iframes, override `xFrameOptions: false`
- `removePoweredBy` defaults to `true` — keep enabled to hide server identity

---

## Environment Variables

### Zod-Validated Env at Startup
Declare all environment variables in a Zod schema in `app/utils/env.server.ts`. Call `init()` in `entry.server.tsx` before any other code.
- TypeScript augmentation (`ProcessEnv extends z.infer<typeof schema>`) gives typed `process.env.X` access across all server code
- Only add vars to `getEnv()` if intentionally public — they are embedded in HTML as `window.ENV`
- Optional integrations use `.optional()` in schema — remove `.optional()` when the integration becomes required
- Never access `process.env` directly in app code outside this module

```ts
declare global {
  namespace NodeJS {
    interface ProcessEnv extends z.infer<typeof schema> {}
  }
}
export function init() {
  const parsed = schema.safeParse(process.env)
  if (!parsed.success) throw new Error('Invalid environment variables')
}
```

---

## Routing

### Auto-Routes via `react-router-auto-routes`
Use `autoRoutes()` in `app/routes.ts`. Never declare routes manually unless there is no filesystem equivalent.
- Files suffixed `.server.*` or `.client.*` are excluded from routing automatically
- Run `react-router typegen` after adding or renaming routes to regenerate `+types/`

---

### Route Layout Groups via `_prefix` Directories
Group routes by layout using underscore-prefixed directories. The prefix is stripped from the URL.
- `_auth/` → anonymous auth flows (login, signup, forgot-password)
- `_marketing/` → public-facing pages
- `resources/` → non-UI resource routes
- Never put auth-protected routes inside `_auth/` — the group is for anonymous screens only

---

### Always Import Route Types from `./+types/`
Every loader, action, and component imports its types from the auto-generated `+types/` module.
- Never write manual type annotations for loader/action args
- Never use `useLoaderData() as LoaderData` — use `Route.ComponentProps` instead

```ts
import { type Route } from './+types/login.ts'
export async function loader({ request }: Route.LoaderArgs) {}
export default function Page({ loaderData }: Route.ComponentProps) {}
```

---

### Config-Based Routing for Complex Cases
Use `app/routes.ts` with `route()` / `index()` when mapping multiple disparate URLs to one component or managing complex nested layouts.
- Useful for legacy URL patterns, markdown-driven routes, or multi-version doc sites
- File-based convention is preferred for standard CRUD routes; config-based is preferred when one layout serves many content URLs

---

### Type-Safe Link Generation via `href()`
Never construct routing URLs manually via string interpolation when they contain parameters.
- Import `href` from `react-router` to validate path and parameter existence at compile time

```ts
<Link to={href('/:locale?/products/:handle', { handle: 'my-product' })}>...</Link>
return redirect(href('/:locale?/subscribe'))
```

---

### Ignore CSS and Test Files in Route Discovery
Configure `ignoredRouteFiles` to exclude CSS and test files.
- Never put test files or CSS inside `app/routes/`
- UI components go in `app/ui/`; shared utilities in `app/lib/` or `app/utils/`

---

## Middleware

### Middleware Factory Pattern — `[middleware, getter]` Tuples
All middleware uses a factory function that returns a `[middleware, getter]` tuple.
- All middleware files MUST be named `*.server.ts` and placed in `~/middleware/`
- Never import middleware factories from `remix-utils` directly in route files — always re-export from your `~/middleware/*.server.ts`
- Add middleware to `export const middleware: Route.MiddlewareFunction[]` — in `root.tsx` for global, in a layout route for scoped

```ts
export const [sessionMiddleware, getSession] = createSessionMiddleware(sessionStorage)
// root.tsx
export const middleware: Route.MiddlewareFunction[] = [sessionMiddleware]
// loader
let session = getSession(context)
```

---

### Context Storage Middleware — First in Array
Use `createContextStorageMiddleware` to access `context`/`request` in deeply nested helpers without prop-drilling.
- **Must be the first middleware in the array** — every other middleware that uses `getContext()` depends on it
- Only call `getContext()` / `getRequest()` inside a middleware chain — never at module init time
- Throws a descriptive error if called outside middleware scope — never catch and swallow it

---

### Cross-Cutting Concerns in Root Middleware Array
Centralize concerns like HTTPS redirects, trailing slashes, and security headers in root middleware.
- Order matters — security/redirect middleware runs before data loaders
- Modularize each concern into a separate factory function

---

## Forms

### Schema-First Validation — Conform + Zod
Define a Zod schema at the route level. Use `parseWithZod` in the action and `getZodConstraint` in the form hook. Never validate form data manually.
- Use `hideFields: ['password']` in `submission.reply()` to strip sensitive fields from the response
- For async validation (DB checks), use `schema: (intent) => Schema.transform(...)` — skip async work when `intent !== null`
- Always return `{ result: submission.reply() }` on failure so the form restores state

---

### Use `namedAction` for Multi-Intent Routes
Use `namedAction` when a route handles multiple form submissions. The intent field name is always `intent`.
- Always define a `default` handler to avoid unhandled `ReferenceError`s
- Works with `FormData` only — not URL search params
- Do not use for separate resource routes — only when multiple forms share one route

```ts
export async function action({ request }: Route.ActionArgs) {
  return namedAction(await request.formData(), {
    async create() { return redirect('/items') },
    async delete() { return redirect('/items') },
    async default() { throw new Response('Unknown action', { status: 400 }) },
  })
}
```

---

### Shared Field Wrapper Components
Never render raw inputs. Always use shared field wrappers that auto-generate `id`, wire `aria-invalid` + `aria-describedby`, and render `<ErrorList>`.
- `CheckboxField` uses `useInputControl` from `@conform-to/react` to bridge Radix state with Conform
- `ErrorList` accepts `Array<string | null | undefined> | null | undefined` — pass `fields.x.errors` directly

---

## Database

### Singleton Prisma Client via `@epic-web/remember`
Export a single `prisma` instance from `app/utils/db.server.ts` using `remember()`. Never instantiate `PrismaClient` anywhere else.
- Import from `@prisma/client/index.js` (not `@prisma/client`) due to a known React Router/HMR issue
- The slow query threshold is 20ms — log anything exceeding it with color-coded severity

```ts
export const prisma = remember('prisma', () => new PrismaClient({ log: [...] }))
```

---

### Always Use Explicit `select` in Prisma Queries
Every Prisma query must specify an explicit `select`. Never fetch full model objects.
- Never return `password.hash` or sensitive fields to the client — explicit `select` enforces this at the query level
- Nested relations also need explicit `select` — do not assume they're excluded

```ts
// ✅ const user = await prisma.user.findUnique({ select: { id: true, name: true }, where: { id } })
// ❌ const user = await prisma.user.findUnique({ where: { id } }) // leaks password hash
```

---

## Error Handling

### Per-Route `ErrorBoundary` Exports
Every route exports an `ErrorBoundary`. Root exports it as last resort; the `$.tsx` catch-all also uses it.
- A single missing `ErrorBoundary` crashes the whole page on a route error
- Map HTTP status codes (404, 400, 409) to dedicated UI components — do not render generic errors for known codes

```tsx
export function ErrorBoundary() {
  return <GeneralErrorBoundary />
}
```

---

### Filter Noise from `handleError`
In `entry.server.tsx`, silently ignore aborted requests and 404s before reporting to error tracking.
- Aborted requests = user navigated away — always safe to ignore
- 404s are usually bot scanners — log locally if needed but do not alert

```ts
export const handleError: HandleErrorFunction = (error, { request }) => {
  if (request.signal.aborted) return
  if (isRouteErrorResponse(error) && error.status === 404) return
  Sentry.captureException(error)
}
```

---

### `getErrorMessage` — Safe Error Extraction
Use `getErrorMessage()` when extracting errors from catch blocks. Never cast `(error as Error).message`.
- Returns the string, `error.message`, or `'Unknown Error'` — always a string

---

## HTTP Headers & Caching

### `pipeHeaders` — Propagate Cache Headers Up the Route Tree
Every route with a loader or action must export `pipeHeaders` as its `headers` function.
- Without `pipeHeaders`, cache headers set in nested routes are silently dropped
- `combineHeaders` uses `append` (preserves duplicate `Set-Cookie`); `mergeHeaders` uses `set` (overwrites)
- Always use `combineHeaders` when setting cookies — using `set` silently drops all but the last cookie

```ts
export const headers: Route.HeadersFunction = pipeHeaders
```

---

### Centralize Cache-Control Constants
Define `Cache-Control` values as named constants in a shared module (e.g., `app/http.ts`). Never hardcode cache strings in route headers exports.

```ts
export const CACHE_CONTROL = {
  doc: 'public, max-age=300, stale-while-revalidate=604800',
  none: 'no-store, no-cache, must-revalidate, max-age=0',
}
```

---

### Caching with `cachified` — Always Use the Local Wrapper
Never import from `@epic-web/cachified` directly — use the re-exported `cachified` from `cache.server.ts`.
- The local wrapper automatically integrates Server-Timing headers for cache miss/hit profiling in DevTools
- Supports `forceFresh` via `?fresh` URL param for admin cache-busting
- Two layers: `lruCache` (in-memory, fast, resets on restart) and `cache` (SQLite, survives deploys)
- Cache keys must be globally unique — prefix with entity type: `user-${id}`, `note-${id}`

---

### Flash Toasts via Cookie Session
Communicate post-redirect notifications via a dedicated flash cookie session. Never use URL params for one-time notifications.
- Types: `message` (neutral), `success` (green), `error` (red)
- `getToast` destroys the toast session after reading — it is flash-only
- `EpicToaster` is rendered in `root.tsx` once — never add to individual routes

```ts
return redirectWithToast('/dashboard', { title: 'Success', description: '...', type: 'success' })
```

---

## Build & Tooling

### Separate Vite Configs — Never Merge
Use separate config files for dev/prod build, Vitest, and Storybook. Never merge them.
- The Remix/React Router Vite plugin intercepts module resolution and SSR transforms — it breaks Vitest and Storybook environments
- `installGlobals()` must be called at module top-level in `vite.config.ts`

| File | Purpose | Remix Plugin |
|---|---|---|
| `vite.config.ts` | Dev + prod | ✅ |
| `vitest.config.ts` | Unit tests | ❌ |
| `vite-sb.config.ts` | Storybook | ❌ |

---

### `vite-env-only` Macros for Server-Only Exports
Use `serverOnly$` and `clientOnly$` from `vite-env-only` to guarantee dead-code elimination in shared files.
- `.server.ts` files are automatically excluded from client bundles by React Router
- The macro is for inline usage within shared files where static analysis cannot determine the scope

```ts
export const DB_URL = serverOnly$(process.env.DATABASE_URL)  // undefined in client bundle
```

---

### SVG Icon Spritesheet — Never Import Raw SVGs
Compile all icons into a single SVG sprite via `vite-plugin-icons-spritesheet`. Never import SVGs directly.
- Source icons in `app/assets/icons/` (or `other/svg-icons/`) — one HTTP request regardless of icon count
- Icon names are typed — TypeScript errors on unknown icon names
- Preload the sprite in `root.tsx` with `fetchPriority="high"` via a hidden `<img>` for LCP optimization

```tsx
<Icon name="check" />
// root.tsx: <img src={iconsHref} alt="" hidden fetchPriority="high" />
```

---

### Path Alias `~/` Maps to `./app/*`
Use `~/` everywhere — never use relative paths to reach into `app/`.
- Configure in both `tsconfig.json` (`paths`) and via `vite-tsconfig-paths` plugin
- Do not duplicate with a manual `resolve.alias` in Vite config — `vite-tsconfig-paths` handles it

---

### Linting & Formatting — Biome, Not ESLint + Prettier
Use Biome for both linting and formatting. Never add ESLint or Prettier.
- `noUnusedVariables` is elevated to `error` (Biome default is `warn`)
- Enforce via Lefthook pre-commit running only on staged files with `stage_fixed: true`

---

## SSR & Streaming

### Split Streaming Strategy by User-Agent
Use `isbot` to detect crawlers and switch `onAllReady` (bots) vs `onShellReady` (browsers).
- Bots need full HTML for indexing — `onShellReady` causes crawlers to index loading skeletons
- `ABORT_DELAY` = 5000ms for both paths
- Log inner stream errors only when `shellRendered === true`
- `onShellError` always rejects the promise and bubbles as 500

---

### Deferred vs. Critical Data in Loaders
Start non-blocking queries immediately; only `await` above-the-fold data.
- Pass non-blocking promises directly to `data()` — resolve client-side via `Suspense`
- Awaiting everything blocks TTFB unnecessarily

```ts
const deferredData = loadDeferredData(context)          // starts, not awaited
const criticalData = await loadCriticalData(context)    // blocks until ready
return data({ ...criticalData, ...deferredData })
```

---

### `<ClientOnly>` for Browser-Dependent Components
Wrap browser-only components in `<ClientOnly>` to prevent SSR errors and hydration mismatches.
- Children MUST be a function `{() => <Component />}` — not JSX directly
- Always provide a `fallback` with matching dimensions to prevent CLS
- Do not use `<ClientOnly>` to avoid SSR-compatible code — fix the component if possible

---

### Wrap `hydrateRoot` in `startTransition`
Always wrap `hydrateRoot` in `startTransition` to defer hydration as a non-urgent update.
- Hydrate `document` (full document), not a specific DOM element
- Always wrap `<RemixBrowser />` in `<StrictMode>`

---

## UI & Components

### Root Layout — `Layout` and `App` Are Always Separate
`root.tsx` exports `Layout` (document shell) and `App` (route tree) as separate functions.
- `Layout` wraps error boundaries — it must be independent of loader data
- Import CSS with `?url` suffix in `links()` — never via bare import (won't be injected into `<head>` correctly)
- `<ScrollRestoration />` must be inside `<body>` before `<Scripts />`

---

### `cn()` — All Conditional Class Names
Use `cn()` (= `clsx` + `tailwind-merge`) for all conditional class strings. Never concatenate manually.
- Later classes override earlier ones: `cn('p-4', 'p-2')` → `'p-2'`

---

### `useGlobalPendingState` — Global Spinner
Use `useGlobalPendingState` in root layout for global loading indicators — not `useNavigation()` alone.
- `useNavigation()` only tracks browser navigations; fetcher submissions are invisible to it
- Place global indicators in `root.tsx` or a shared layout — not per-route

---

### `useDelayedIsPending` — Avoid Loading State Flash
Use `useDelayedIsPending` with `delay: 400` and `minDuration: 300` instead of raw `navigation.state`.
- Prevents a flash of loading UI for sub-400ms responses
- Use `StatusButton` with `status={isPending ? 'pending' : form.status ?? 'idle'}`

---

### `useDoubleCheck` — Destructive Action Confirmation
Use `useDoubleCheck` for destructive actions (delete, revoke). Requires two clicks — no modal overhead.
- First click: shows confirmation label, prevents submission
- Second click (or blur/Escape): submits or resets

---

### `useOptionalUser` / `useUser` — Root Loader Access
Access the current user from root loader data via `useOptionalUser()` or `useUser()`. Never prop-drill user data.
- These hooks use `useRouteLoaderData('root')` — work from any component
- `useUser()` throws a descriptive error if used in an unauthenticated context

---

### UI Component Colocation — One Folder per Component
Each UI component lives in `app/ui/[category]/[ComponentName]/` with co-located `.tsx`, `.stories.tsx`, `.spec.tsx`.
- Tests import from `.stories.tsx` via `composeStories()` — never duplicate fixture setup
- Story file is required alongside every UI component
- Named exports only for components — no default exports

---

### Client Hints — Prevent SSR Theme Flash
Use `@epic-web/client-hints` to prevent hydration mismatches for user preferences (theme, timezone).
- Inject `<ClientHintCheck>` in `<head>` before render
- Forces a page reload if cookie hint is missing or stale — ensures server and client match
- Parse color scheme in root loader; inject `className={colorScheme === 'dark' ? 'dark' : ''}` on `<html>`

---

### Route Handle Pattern — Typed Metadata via `handle` Export
Use the `handle` export for route-specific metadata (sitemap entries, breadcrumbs, layout flags). Read with `useMatches()` in root or parent routes.
- Define a typed `Handle` type for the project — do not use untyped object literals

---

### Delegated Markdown Links
When rendering HTML from `dangerouslySetInnerHTML`, use a delegation hook to intercept `<a>` clicks and route them through React Router.
- Raw HTML anchors trigger full page reloads — `useDelegatedReactRouterLinks(ref)` converts them to SPA navigations

---

### LLM Markdown Meta Tag
Expose raw markdown source to AI scrapers via a custom `llm-markdown` meta tag.
- Directs LLMs to the raw markdown URL instead of parsing rendered DOM HTML

---

## Real-Time

### SSE via `eventStream` + `useEventSource`
Use Server-Sent Events for server-to-client push. Live in a resource route.
- The `setup` function MUST return a cleanup/unsubscribe function — always clean up on disconnect
- The `AbortSignal` from `request.signal` closes the stream on client disconnect — always pass it
- Multiple components sharing the same hook params share ONE connection (global URL-keyed map)
- Do not use debounce fetchers for live data — SSE is the correct pattern for server push

---

### CORS — Middleware for More Than 2 Routes
Use `createCorsMiddleware` globally for consistent CORS. Use per-loader `cors()` only for 1-2 specific API routes.
- `origin: true` allows any origin — always restrict in production
- Preflight `OPTIONS` requests are handled automatically

---

## Flagged (Score 2 — Review Needed)

- **Tailwind v4 setup** (remix-boilerplate): Uses `@tailwindcss/postcss` + `tailwind.config.ts` pattern. Confirm whether the project uses Tailwind v4 CSS-first config or still needs the `tailwind.config.ts`. The two are not compatible.
- **Route naming conventions** (remix-boilerplate): `_index.tsx`, `blog.$slug.tsx`, `blog_.new.tsx` — standard Remix file convention, but worth documenting explicitly for teams new to the framework.
- **Storybook integration** (remix-boilerplate): CSS import in `preview.ts` differs from Remix root (`?url` not used in Storybook). Worth a comment in each file to explain why.
- **Image optimization via `openimg`** (epic-stack): Stores object keys in DB and resolves via resource route. Opinionated to Tigris/S3 storage — only adopt if using S3-compatible storage.
- **Server-Timing propagation**: Both epic-stack (`pipeHeaders`) and kentcdodds.com (`reuseUsefulLoaderHeaders`) solve the same problem differently. <!-- CONFLICT: pipeHeaders (epic-stack, merge-conservative) vs reuseUsefulLoaderHeaders (kentcdodds.com, forward-only) — prefer pipeHeaders for new projects; reuseUsefulLoaderHeaders is simpler for read-only cache routes -->
- **Hydrogen Cart Actions** (remix-store): Shopify-specific. Only relevant if using Shopify Hydrogen. Dropped from general standards.
- **LLM markdown meta** (react-router-website): Niche pattern for doc sites. Useful for public documentation but not for SaaS apps.
