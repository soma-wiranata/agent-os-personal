---
source: remix
category: forms
---
# Form vs Fetcher

Use `<Form>` for main mutations that result in redirects or full route navigation, and use `useFetcher` for inline or side-effect mutations that must update data without altering the active URL.

```typescript
import { Form, useFetcher } from 'react-router';

// Use <Form> for operations that navigate or redirect
function LoginForm() {
  return (
    <Form method="post" action="/auth/login">
      <button type="submit">Sign In</button>
    </Form>
  );
}

// Use fetcher for inline actions like toggles or deletions
function DeleteButton({ id }: { id: string }) {
  const fetcher = useFetcher();
  return (
    <fetcher.Form method="post" action={`/items/${id}/delete`}>
      <button type="submit">Delete</button>
    </fetcher.Form>
  );
}
```

- `<Form>` manages standard full-page navigation, scroll resetting, and history updates.
- `useFetcher` keeps the URL intact, prevents layout scroll jumps, and is perfect for background tasks or inline list item mutations.
- `useFetcher.load()` allows fetching data on demand from secondary routes without navigating away from the user's current view.
