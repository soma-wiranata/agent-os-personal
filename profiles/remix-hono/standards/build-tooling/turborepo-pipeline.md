---
source: shared
category: build-tooling
---
# Turborepo Pipeline

Define `build`, `dev`, `typecheck`, `test`, and `lint` tasks in the central `turbo.json` with strict upstream dependency pipelines.

```json
{
  "tasks": {
    "build": { "dependsOn": ["^build"], "outputs": ["dist/**"] },
    "dev":   { "persistent": true, "cache": false },
    "typecheck": { "dependsOn": ["^build"] },
    "test":  { "dependsOn": ["^build"] },
    "lint":  {}
  }
}
```

- Enforces that upstream libraries compile first during `build` by specifying the `^build` depends-on array.
- Configures `dev` tasks with `persistent: true` and caching disabled to facilitate simultaneous development servers.
- Permits global orchestration since Turborepo automatically ignores workspace packages that omit specific task names.
