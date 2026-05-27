---
source: remix
category: security
---
# CSRF — Token-Based (Legacy Only)

Use only when `Sec-Fetch-Site` is not reliable. Requires `@oslojs/crypto`.
- Generate and commit token in root loader; provide via `AuthenticityTokenProvider` in root component
- Inject `<AuthenticityTokenInput />` in every form; validate with `csrf.validate(request)` in actions
- Throw 403 on `CSRFError` — never expose internal error codes to the client

<!-- CONFLICT: header-based (csrf-middleware) vs token-based (csrf-token) — prefer header-based for all new projects -->
