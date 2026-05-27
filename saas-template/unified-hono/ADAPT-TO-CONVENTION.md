# Adaptation Guide: Unified Standards to `/discover-standards` Convention

This guide explains how to convert the unified multi-rule files in `standards/unified/` into the official, highly modular format required by the **`/discover-standards`** convention (and supported by `agent-os` tools like `/inject-standards`). 

This document is self-contained and serves as a **direct prompt** that can be provided to an AI agent to execute the migration automatically when needed.

---

## 📋 The Structural Mismatch

The standards in `standards/unified/` are currently optimized for **human curation and review** using the `curator-standards.md` rubric. They differ significantly from the official, tool-injectable **`/discover-standards`** convention:

| Metric | Current Unified Format (`standards/unified/`) | `/discover-standards` Convention |
| :--- | :--- | :--- |
| **File Density** | **Coarse:** One large file per overall area containing multiple rules. | **Granular:** One file per single concept/rule. |
| **Directory Layout** | `standards/unified/[area].md` | `agent-os/standards/[area]/[concept-slug].md` |
| **Index File** | None (only a static Markdown README table). | `agent-os/standards/index.yml` registering every concept with a description. |
| **Aesthetic Wrap** | Structured with curation metadata (Score 3 vs Flagged Score 2). | Strictly concise, context-minimized, AI-scannable bullet points. |

---

## 🎯 Target Convention Specifications

When converting to the `/discover-standards` convention, you must strictly adhere to the following architecture:

### 1. Folder Structure
All outputs must be written inside the `agent-os` directory:
```
agent-os/
└── standards/
    ├── index.yml
    ├── api/
    │   ├── context-helpers.md
    │   └── typed-app-instantiation.md
    ├── database/
    │   └── primary-keys.md
    └── [area]/
        └── [concept-slug].md
```

### 2. Standalone Concept Files
Each rule gets its own file. The format of the file is extremely clean and stripped of all meta-headings or ratings:
```markdown
# [Concept Name]

[One-sentence imperative rule. e.g. "Always X" or "Never Y"]

```[language]
[Clear, highly relevant code example showing correct implementation]
```

- [Bullet 1: Concrete "why" or benefit]
- [Bullet 2: Exception, boundary condition, or specific pitfall to avoid]
- [Bullet 3: Common mistake or anti-pattern (if applicable)]
```
*Note: Do not include introductory text, explanations, or meta-comments outside the rule, code, and 1–3 bullets. Every word costs tokens in context windows.*

### 3. The `index.yml` Layout
A central index file lists all concepts, organized alphabetically by area folder, then by concept slug:
```yaml
[area]:
  [concept-slug]:
    description: [One-sentence, clear, tool-scannable description of what the rule enforces]
```

---

## 🚀 Migration Prompt (Copy & Paste to Execute)

If you are tasked with executing the migration, copy the following system prompt and run it over the files in `standards/unified/`:

```markdown
You are a precision refactoring agent. Your task is to migrate our unified area standards files from `standards/unified/` into the modular `/discover-standards` structure under the `agent-os/` folder.

For each unified area file (e.g. `api.md`, `db.md`, `auth.md`, `middleware.md`, `testing.md`, `cloudflare.md`):

1. IDENTIFY ALL SCORE 3 (KEEP) RULES:
   - Extract every distinct rule in the main "Rules" section.

2. CREATE STANDALONE FILES:
   - For each rule, create a file at `agent-os/standards/[area]/[concept-slug].md`.
   - Name the file after the concept, using kebab-case (e.g., "Context Helpers" becomes "context-helpers.md").
   - Follow the precise layout:
     - `# [Concept Name]` as the single H1.
     - Single-line imperative rule.
     - Triple-fenced code example.
     - 1 to 3 concise, scannable bullet points explaining why/exceptions/mistakes.

3. CONSTRUCT INDEX.YML:
   - Create or append entries to `agent-os/standards/index.yml`.
   - Group them under the correct folder key (e.g., `api:`, `testing:`).
   - Write a clear, scannable description for each standard.
   - Maintain alphabetical ordering of folders and concept slugs.

4. HANDLE FLAGGED (SCORE 2) RULES:
   - Rules in the "Flagged (Score 2 — Review Needed)" section MUST NOT be migrated automatically.
   - List these flagged rules in a separate report, or present them to the user one by one for promotion before conversion.
```

---

## 💡 Concrete Conversion Example

Here is how a rule is transformed from the unified format into the `/discover-standards` convention:

### 1. Before: Source Rule in `standards/unified/api.md`
```markdown
### Context Helpers

Always use Hono's built-in `c` (Context) helpers for constructing responses instead of returning raw `Response` objects.

- Use `c.json()` for API endpoints, `c.text()` for plain text/webhooks, `c.html()` for HTML
- Use `c.notFound()` and `c.redirect()` for their respective behaviors
- Never return `new Response(JSON.stringify(...), { headers: {...} })` in any handler
```

### 2. After: Standalone Concept File `agent-os/standards/api/context-helpers.md`
```markdown
# Context Helpers

Always use Hono's built-in `c` (Context) helpers for constructing responses instead of returning raw `Response` objects.

```typescript
// Good
app.get('/api/users', (c) => {
  return c.json({ users: [] })
})

// Bad
app.get('/api/users', () => {
  return new Response(JSON.stringify({ users: [] }), {
    headers: { 'Content-Type': 'application/json' }
  })
})
```

- Ensures Hono can apply framework-level middleware modifications (e.g., CORS headers, custom envelopes) to the response stream.
- Provides type safety and automated response shape inference for routing clients.
- Prevents missing headers and manual serialization bugs in route handlers.
```

### 3. After: Registration in `agent-os/standards/index.yml`
```yaml
api:
  context-helpers:
    description: Enforces use of Hono's built-in context helper methods (c.json, c.text) over raw responses
```

---

## ⚠️ Handling Flagged (Score 2) Rules

The unified files contain a section at the bottom for "Flagged (Score 2 — Review Needed)" rules (e.g., generic rules like "Always write clean tests" or "Use consistent variable names").

During migration:
1. **Do not create files for them automatically.**
2. **Review & Refine:** If a flagged rule is deemed useful, rewrite it to be highly specific to the Hono, Cloudflare, or Better Auth context before converting it into a standard file.
3. **Discard:** If the rule is too generic or represents general software craftsmanship best practices, drop it entirely to keep the AI context footprint minimal.
