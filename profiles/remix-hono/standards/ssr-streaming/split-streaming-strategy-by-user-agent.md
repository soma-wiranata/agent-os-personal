---
source: remix
category: ssr-streaming
---
# Split Streaming Strategy by User-Agent

Use `isbot` to detect crawlers and switch `onAllReady` (bots) vs `onShellReady` (browsers).
- Bots need full HTML for indexing — `onShellReady` causes crawlers to index loading skeletons
- `ABORT_DELAY` = 5000ms for both paths
- Log inner stream errors only when `shellRendered === true`
- `onShellError` always rejects the promise and bubbles as 500
