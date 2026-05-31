# AI System Instruction: React Router v7 (Remix) Architecture Guide

## 1. Core Framework Context

- **The Paradigm:** "Remix" is now **React Router v7** running in "Framework Mode." Ignore all file-system routing conventions from Remix v1/v2 tutorials — they are obsolete.
- **The Architecture:** Built on web standards (Fetch API, standard `Request`/`Response`) with progressive enhancement — native HTML forms that work without JS, enhanced by JS when available.
- **The Data Pipeline:** Every route file owns its full data lifecycle via four core exports:
  1. `loader` — Server-only GET. Fetches data before render.
  2. `action` — Server-only POST/PUT/DELETE. Handles form mutations.
  3. `default Component` — Renders UI using data from `loader`.
  4. `ErrorBoundary` — Catches and displays route-level errors. **Always export one.**

---

## 2. AI Guardrails (Anti-Context-Drift)

Strictly enforce these rules. Do not deviate.

- **Rule 1: routes.ts is the only routing truth.** All routes are declared explicitly in `app/routes.ts`. Never infer routing from filenames. Never use filename-based conventions (dots, underscores, dollar signs from old Remix).
- **Rule 2: Strict feature colocation.** Keep DB queries, helpers, and UI components inside the module folder they belong to. Move code to `shared/` only when a *second distinct module* needs it.
- **Rule 3: Enforce `.server.ts` boundaries.** Files with direct DB access, secret env vars, or heavy backend logic must use the `.server.ts` extension. This prevents server code from leaking into the client bundle.
- **Rule 4: Always use generated route types.** RRv7 generates `+types/` files per route. Never manually type `loader`, `action`, or component props — always import from the generated type file.

---

## 3. Strict Package Manifest

Use only these libraries for their domains. Do not suggest alternatives (Lucia, Prisma, React Hook Form, MUI) unless explicitly instructed.

| Domain | Package |
|---|---|
| Forms & Validation | `@conform-to/react` + `zod` |
| Authentication | `better-auth` |
| Database / ORM | `drizzle-orm` |
| UI Components | `shadcn/ui` + `tailwindcss` |
| Icons | `lucide-react` |

---

## 4. Repository Blueprint

```text
app/
├── root.tsx                    # Root HTML shell & global layout providers
├── routes.ts                   # SOURCE OF TRUTH: all routes declared here
├── entry.server.tsx            # Server render entry (streaming, headers)
├── entry.client.tsx            # Client hydration entry
│
└── modules/
    ├── tasks/
    │   ├── components/         # UI components used only by tasks
    │   ├── queries.server.ts   # All DB queries for tasks (never imported by client)
    │   ├── route-list.tsx      # Loader + Action + View + ErrorBoundary for /tasks
    │   └── route-detail.tsx    # Loader + Action + View + ErrorBoundary for /tasks/:id
    │
    ├── billing/
    │   ├── components/
    │   ├── queries.server.ts
    │   └── route-manage.tsx
    │
    └── shared/                 # ONLY code used by 2+ distinct modules lives here
        ├── components/         # Global UI primitives (Button, Modal, etc.)
        ├── utils/              # Shared helpers (date formatters, math, etc.)
        └── db.server.ts        # Drizzle client instance
```

---

## 5. Code Implementation Standards

### A. Central Routing Table (`app/routes.ts`)

```typescript
import { type RouteConfig, route, index } from "@react-router/dev/routes";

export default [
  index("modules/home/route-home.tsx"),
  route("tasks", "modules/tasks/route-list.tsx"),
  route("tasks/:id", "modules/tasks/route-detail.tsx"),
  route("billing", "modules/billing/route-manage.tsx"),
] satisfies RouteConfig;
```

---

### B. Unified Feature File Pattern (`app/modules/tasks/route-list.tsx`)

**Always import generated route types. Never type loader/action args manually.**

```typescript
// 1. ALWAYS import generated types from +types/ — never type args manually
import type { Route } from "./+types/route-list";

import { Form, useFetcher } from "react-router";
import { parseWithZod } from "@conform-to/zod";
import { z } from "zod";
import { db } from "../shared/db.server";
import { tasksTable } from "./queries.server";

// 2. SHARED VALIDATION SCHEMA
const taskSchema = z.object({
  title: z.string().min(1, "Title is required"),
});

// 3. META (always export for SEO)
export const meta: Route.MetaFunction = () => [
  { title: "My Tasks" },
];

// 4. LOADER — typed via Route.LoaderArgs, not manual typing
export async function loader({ request }: Route.LoaderArgs) {
  const tasks = await db.select().from(tasksTable);
  return { tasks };
}

// 5. ACTION — typed via Route.ActionArgs
export async function action({ request }: Route.ActionArgs) {
  const formData = await request.formData();
  const submission = parseWithZod(formData, { schema: taskSchema });

  if (submission.status !== "success") {
    return submission.reply();
  }

  await db.insert(tasksTable).values({ title: submission.value.title });
  return { success: true };
}

// 6. VIEW — use loaderData from Route.ComponentProps, not useLoaderData
export default function TaskListRoute({ loaderData }: Route.ComponentProps) {
  const { tasks } = loaderData;

  // useFetcher: for mutations that should NOT trigger navigation
  // Use this for inline edits, toggles, deletes within a list item
  // Use <Form> when the mutation should redirect or refresh the whole route
  const fetcher = useFetcher();

  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">My Tasks</h1>

      <ul className="mb-4 space-y-2">
        {tasks.map((task) => (
          <li key={task.id} className="flex items-center justify-between p-2 border rounded">
            <span>{task.title}</span>
            {/* useFetcher for inline delete — no full page navigation */}
            <fetcher.Form method="post">
              <input type="hidden" name="intent" value="delete" />
              <input type="hidden" name="taskId" value={task.id} />
              <button type="submit" className="text-red-500 text-sm">Delete</button>
            </fetcher.Form>
          </li>
        ))}
      </ul>

      {/* <Form> for main mutations that should refresh route data */}
      <Form method="post" className="flex gap-2">
        <input
          type="text"
          name="title"
          placeholder="New task..."
          className="border p-2 rounded"
        />
        <button type="submit" className="bg-blue-500 text-white px-4 py-2 rounded">
          Add Task
        </button>
      </Form>
    </div>
  );
}

// 7. ERROR BOUNDARY — always export, never skip
export function ErrorBoundary({ error }: Route.ErrorBoundaryProps) {
  return (
    <div className="p-4 text-red-600">
      <h2 className="font-bold">Something went wrong</h2>
      <p>{error instanceof Error ? error.message : "Unknown error"}</p>
    </div>
  );
}
```

---

### C. When to Use `<Form>` vs `useFetcher`

| Scenario | Use |
|---|---|
| Submit creates/updates and should redirect or reload the route | `<Form method="post">` |
| Inline toggle, delete, or update within a list without navigation | `useFetcher` |
| Loading data from another route without navigating | `useFetcher.load("/some-route")` |

---

### D. Standard API Response Shape

All server responses (loaders, actions, and any API routes) must use this consistent envelope:

```typescript
// Success
{ success: true, data: { ... } }

// Error
{ success: false, error: { message: string; code?: string } }
```

This ensures predictable handling on the client and aligns with the Hono backend response contract.
