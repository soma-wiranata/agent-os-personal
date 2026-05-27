# Unified Hono Backend Standards

This directory contains the **curated, deduplicated, and scored** standards extracted from 13 source repositories, processed through the [`curator-standards.md`](../../curator-standards.md) rubric.

## What's Here

Each file is a standalone, AI-injectable standards document for one area of the backend stack.

| File | Area | Rule Count |
|---|---|---|
| [api.md](./api.md) | API routing, responses, error handling, validation, background tasks | 14 rules |
| [db.md](./db.md) | Drizzle ORM, schemas, types, soft deletes, D1, Hyperdrive | 9 rules |
| [auth.md](./auth.md) | Better Auth, session middleware, CORS, cookies, Cloudflare auth | 8 rules |
| [middleware.md](./middleware.md) | App factory, middleware factories, SDK singletons, logging | 6 rules |
| [testing.md](./testing.md) | Vitest, testClient, DB isolation, OpenAPI contract tests | 4 rules |
| [cloudflare.md](./cloudflare.md) | Workers deployment, static assets, SSR, Vite proxy, Grammy bots | 5 rules |

## Curation Process Applied

- **Score 3 (Kept):** Opinionated, specific, non-obvious rules a new developer or AI would NOT arrive at without being told
- **Score 2 (Flagged):** Useful but generic rules — listed in each file's "Flagged" section for manual review
- **Score 1 (Dropped):** Framework defaults and obvious best practices (e.g. "use TypeScript", "handle errors")

## How to Use

- Use `/inject-standards` to pull specific files into active coding contexts
- Reference a single file when working on a specific area (e.g., reference `auth.md` before implementing auth flows)
- The "Flagged" sections in each file require a human decision before being promoted to enforced rules
