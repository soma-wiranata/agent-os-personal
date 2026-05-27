---
source: hono
category: auth
---
# Cross-Subdomain Authentication

Configure `better-auth` for cross-subdomain cookie sharing when running multi-service monorepos.

```typescript
{
  advanced: {
    crossSubDomainCookies: { enabled: true, domain: '.yourdomain.com' },
  },
  trustedOrigins: ['https://yourdomain.com', 'https://api.yourdomain.com'],
}
```

- Allows users to log in once and be authenticated across all subdomains automatically
- Disable in local development when running on `localhost` without proper subdomains
