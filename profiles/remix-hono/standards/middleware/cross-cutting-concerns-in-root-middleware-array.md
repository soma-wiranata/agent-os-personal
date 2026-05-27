---
source: remix
category: middleware
---
# Cross-Cutting Concerns in Root Middleware Array

Centralize concerns like HTTPS redirects, trailing slashes, and security headers in root middleware.
- Order matters — security/redirect middleware runs before data loaders
- Modularize each concern into a separate factory function
