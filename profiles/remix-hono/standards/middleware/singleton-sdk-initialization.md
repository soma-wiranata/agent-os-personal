---
source: hono
category: middleware
---
# Singleton SDK Initialization

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
