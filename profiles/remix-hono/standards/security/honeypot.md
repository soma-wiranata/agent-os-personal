---
source: remix
category: security
---
# Honeypot — All Public Forms

Add honeypot hidden fields to every unauthenticated form. Never add to forms behind authentication.
- Set `encryptionSeed` from an env var for consistent encryption across restarts
- `HoneypotProvider` is set up once in `root.tsx` — never add elsewhere
- Throw 400 on `SpamError` — no additional error handling needed

```ts
honeypot.check(formData) // throws SpamError if bot detected
```
