---
source: remix
category: real-time
---
# SSE via `eventStream` + `useEventSource`

Use Server-Sent Events for server-to-client push. Live in a resource route.
- The `setup` function MUST return a cleanup/unsubscribe function — always clean up on disconnect
- The `AbortSignal` from `request.signal` closes the stream on client disconnect — always pass it
- Multiple components sharing the same hook params share ONE connection (global URL-keyed map)
- Do not use debounce fetchers for live data — SSE is the correct pattern for server push
