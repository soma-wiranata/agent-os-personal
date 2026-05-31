# Agent OS: Remix-Hono Standards Handoff Documentation

Welcome! This document provides a highly granular, context-rich handoff of the **Agent OS** project, with a specific focus on the **Remix-Hono standards profile**. 

This document is designed to give you (another AI agent) an immediate, comprehensive understanding of the system architecture, directory layouts, and how each component operates, complete with exact absolute file paths.

---

## 🚀 1. Overview of Agent OS

**Agent OS** is an AI-first framework designed to establish codebase standards, intelligently index/inject those standards into active AI coding assistants (such as Claude Code, Cursor, and the **Google Antigravity IDE**), and enforce consistent development workflows.

### 📌 Core Mission & v3.0 Evolution
Since **v3.0**, Agent OS has shifted from orchestrating task execution to focusing entirely on its core strengths:
- **Standards Discovery:** Surfacing best practices directly from source code.
- **Standards Injection:** Delivering context-minimized, highly modular rules into active LLM sessions exactly when needed.
- **Spec-Driven Design:** Leveraging modern AI "Plan Modes" to shape requirements into concrete specs before writing code.

---

## 📁 2. Architecture & File Layout

Below is the directory structure for the core components of the Remix-Hono standards implementation:

```
d:\SaaS-projects\agent-os-source\
├── config.yml                               # Main project configuration (profile inheritance)
├── commands\
│   └── agent-os\                            # Agent OS system commands (prompt files)
│       ├── discover-standards.md
│       ├── index-standards.md
│       ├── inject-standards.md
│       ├── plan-product.md
│       └── shape-spec.md
├── scripts\                                 # System execution scripts (Bash & PowerShell)
│   ├── common-functions.sh
│   ├── project-install.sh
│   ├── project-install.ps1                  # Antigravity PowerShell installation engine
│   ├── sync-to-profile.sh
│   ├── sync-to-profile.ps1                  # Antigravity PowerShell profile syncing engine
│   └── split-standards.js                   # The unified-to-split standards parsing engine
├── saas-template\                           # Source repository for human-facing unified standards
│   ├── unified-standards-remix.md           # The primary unified Remix standards file
│   └── unified-hono\                        # Unified Hono standards directory
│       ├── README.md
│       ├── ADAPT-TO-CONVENTION.md
│       ├── api.md
│       ├── auth.md
│       ├── cloudflare.md
│       ├── db.md
│       ├── middleware.md
│       └── testing.md
└── profiles\
    └── remix-hono\                          # The core Remix-Hono target profile folder
        └── standards\                       # Highly modular, split standards (100+ files)
            ├── index.yml                    # Auto-generated master catalog index
            ├── api\
            ├── auth\
            ├── build-tooling\
            ├── cloudflare\
            ├── database\
            ├── env\
            ├── error-handling\
            ├── forms\
            ├── headers-caching\
            ├── middleware\
            ├── real-time\
            ├── routing\
            ├── security\
            ├── ssr-streaming\
            ├── testing\
            └── ui-components\
```

---

## 🔍 3. The Core Concept: Remix-Hono Standards

The **remix-hono** profile establishes strict conventions for building full-stack applications with a **Remix frontend** (React SSR) and a **Hono backend** (often hosted on serverless/edge environments like Cloudflare Workers). 

To balance human-readability with efficient AI consumption, these standards exist in two separate representations:

### A. The Unified Standards (Human Curation)
Located inside the [saas-template/](file:///d:/SaaS-projects/agent-os-source/saas-template) directory, these files gather rules into cohesive areas for easy manual review. They include metadata, rationale, and a **Score** based on `curator-standards.md`:
- **Score 3 (Keep):** Opinionated, specific rules that a new developer or AI would not naturally deduce.
- **Score 2 (Flagged):** Generic or questionable rules requiring human review before conversion.
- **Score 1 (Dropped):** Standard framework boilerplate or obvious code quality practices.

#### Exact Paths:
- [saas-template/unified-standards-remix.md](file:///d:/SaaS-projects/agent-os-source/saas-template/unified-standards-remix.md) — Contains the unified frontend standards for Remix.
- [saas-template/unified-hono/api.md](file:///d:/SaaS-projects/agent-os-source/saas-template/unified-hono/api.md) — Hono routing, envelopes, background processing, and RPC bridges.
- [saas-template/unified-hono/db.md](file:///d:/SaaS-projects/agent-os-source/saas-template/unified-hono/db.md) — Database mapping, Prisma/Drizzle configuration, migrations, soft deletes, and Cloudflare D1/Hyperdrive.
- [saas-template/unified-hono/auth.md](file:///d:/SaaS-projects/agent-os-source/saas-template/unified-hono/auth.md) — Session management, CORS scoping, double-cookie structures, and Better Auth configuration.
- [saas-template/unified-hono/middleware.md](file:///d:/SaaS-projects/agent-os-source/saas-template/unified-hono/middleware.md) — App factory pattern, context storage middleware, and SDK singletons.
- [saas-template/unified-hono/testing.md](file:///d:/SaaS-projects/agent-os-source/saas-template/unified-hono/testing.md) — Vitest, test client isolation, OpenAPI schema verification, and factories.
- [saas-template/unified-hono/cloudflare.md](file:///d:/SaaS-projects/agent-os-source/saas-template/unified-hono/cloudflare.md) — Deployment bounds, environment bindings, Vite development proxies, and Grammy Telegram webhook bots.

---

### B. The Split Standards (Modular & AI-Scannable)
Located in [profiles/remix-hono/standards/](file:///d:/SaaS-projects/agent-os-source/profiles/remix-hono/standards), this directory contains **over 100 granular files**. 

#### Why split?
Large files consume excessive tokens and pollute active context windows. By breaking standards down into one rule per file, tools like `/inject-standards` can pull in only the specific, highly relevant rules required for the current task.

#### Structure of a Split Standard File:
Each file contains:
1. A frontmatter block (`source` and `category`).
2. A single H1 naming the concept.
3. An imperative, single-line rule.
4. A highly focused, triple-fenced code block showing correct implementation.
5. A list of 1–3 concise bullet points outlining the concrete benefits, exceptions, or common anti-patterns.

---

## 🛠️ 4. Active Scripts & How They Work

### 🚀 A. The Parsing Engine: `split-standards.js`
- **Path:** [scripts/split-standards.js](file:///d:/SaaS-projects/agent-os-source/scripts/split-standards.js)
- **Function:** Reads the unified files, parses the markdown, isolates **Score 3 (Keep)** rules (ignoring flagged Score 2 sections), converts rule headings into kebab-case slugs, and generates over 100 individual files under `profiles/remix-hono/standards/`.
- **Master Index Generation:** It compiles [profiles/remix-hono/standards/index.yml](file:///d:/SaaS-projects/agent-os-source/profiles/remix-hono/standards/index.yml) which functions as the primary catalog. The `/inject-standards` command scans this index file to locate modular standards.

### 🔄 B. The Synchronization Engines
These scripts copy modified project-specific standards back to the base profile configurations:
- **Bash Sync:** [scripts/sync-to-profile.sh](file:///d:/SaaS-projects/agent-os-source/scripts/sync-to-profile.sh)
- **PowerShell Sync:** [scripts/sync-to-profile.ps1](file:///d:/SaaS-projects/agent-os-source/scripts/sync-to-profile.ps1)

### 📦 C. The Installation Engines
These scripts handle fresh project-specific installations of Agent OS:
- **Bash Installer:** [scripts/project-install.sh](file:///d:/SaaS-projects/agent-os-source/scripts/project-install.sh)
- **PowerShell Installer:** [scripts/project-install.ps1](file:///d:/SaaS-projects/agent-os-source/scripts/project-install.ps1)

---

## 💻 5. Agent OS Commands: Exact Prompt Instructions

The `commands/agent-os/` directory contains standard instructions that prompt active agents to behave according to Agent OS rules:

1. **[discover-standards.md](file:///d:/SaaS-projects/agent-os-source/commands/agent-os/discover-standards.md)**
   - *How it works:* Commands the agent to scan the current codebase to detect and write down new, modular standards that are not yet documented.
2. **[inject-standards.md](file:///d:/SaaS-projects/agent-os-source/commands/agent-os/inject-standards.md)**
   - *How it works:* Guides the agent in parsing the project's `index.yml` file, matching the user's active requirements against those standards, and programmatically loading relevant standard files into the context.
3. **[shape-spec.md](file:///d:/SaaS-projects/agent-os-source/commands/agent-os/shape-spec.md)**
   - *How it works:* Directs the agent to grill the user with clarifying design/business questions before drafting a formal spec file.
4. **[index-standards.md](file:///d:/SaaS-projects/agent-os-source/commands/agent-os/index-standards.md)**
   - *How it works:* Instructs the agent on how to update and maintain alphabetical order of the master `index.yml` catalog when new standards are written.
5. **[plan-product.md](file:///d:/SaaS-projects/agent-os-source/commands/agent-os/plan-product.md)**
   - *How it works:* Standardizes product roadmapping, vision documentation, and base tech stack selection.

---

## 🧠 Quick Start Guide for Incoming AI Agents

If you are a newly initialized agent looking to work on Remix-Hono standards:

1. **Referencing Standards:** Before writing any code related to Remix-Hono, look up the target category in [profiles/remix-hono/standards/index.yml](file:///d:/SaaS-projects/agent-os-source/profiles/remix-hono/standards/index.yml) to discover relevant rules.
2. **Re-splitting Standards:** If you modify human-readable unified standards (e.g. `saas-template/unified-standards-remix.md`), execute the splitting engine to rebuild the granular directories:
   ```bash
   node scripts/split-standards.js
   ```
3. **PowerShell Usage:** Under Windows/Antigravity console environments, execute PowerShell-equivalent scripts (e.g., `scripts/sync-to-profile.ps1`) to perform installation or sync tasks.
