---
source: remix
category: routing
---
# Feature Module Colocation

Keep all related components, server queries, and route definitions colocated inside dedicated feature directories under `app/modules/[feature]/` before promoting them to global shared directories.

```text
app/modules/tasks/
├── components/
│   └── task-card.tsx
├── queries.server.ts
├── route-list.tsx
└── route-detail.tsx
```

- Prevents premature abstraction and complex imports by grouping files that change together.
- Mirroring the feature-sliced backend structure maintains cognitive consistency across both parts of the repository.
- Code should only be moved to a global `shared/` directory when at least two distinct feature modules actively require it.
