---
source: shared
category: database
---
# Migrations Deploy Integration

Run database migrations automatically as part of the deployment process instead of executing them manually.

```bash
# Cloudflare D1 automatic deployment migration
npx wrangler d1 migrations apply <DB_NAME> --remote
```

- Automates wrangler migration applications for D1 edge databases or starts Node/Bun `db:migrate` scripts on container boot.
- Requires passing connection details directly to the client factory rather than reading `process.env` inside the shared package.
- Protects database stability by eliminating inconsistent manually run CLI migrations.
