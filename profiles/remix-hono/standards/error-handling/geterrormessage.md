---
source: remix
category: error-handling
---
# `getErrorMessage` — Safe Error Extraction

Use `getErrorMessage()` when extracting errors from catch blocks. Never cast `(error as Error).message`.
- Returns the string, `error.message`, or `'Unknown Error'` — always a string
