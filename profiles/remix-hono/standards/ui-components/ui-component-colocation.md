---
source: remix
category: ui-components
---
# UI Component Colocation — One Folder per Component

Each UI component lives in `app/ui/[category]/[ComponentName]/` with co-located `.tsx`, `.stories.tsx`, `.spec.tsx`.
- Tests import from `.stories.tsx` via `composeStories()` — never duplicate fixture setup
- Story file is required alongside every UI component
- Named exports only for components — no default exports
