---
source: remix
category: auth
---
# DB-Backed Sessions — Cookie Holds ID Only

Store session data in the database. The cookie holds only the `sessionId`. Never store user data directly in the session cookie.
- If the session row is missing or expired, destroy the cookie immediately and redirect to `/`
- `SESSION_SECRET` supports key rotation via comma-separated values: `SECRET1,SECRET2`
- DB expiration is enforced at query time: `expirationDate: { gt: new Date() }`

```ts
export const authSessionStorage = createCookieSessionStorage({
  cookie: { name: 'en_session', sameSite: 'lax', httpOnly: true,
            secrets: process.env.SESSION_SECRET.split(','),
            secure: process.env.NODE_ENV === 'production' }
})
export async function getUserId(request: Request) {
  const sessionId = (await authSessionStorage.getSession(request.headers.get('cookie'))).get(sessionKey)
  if (!sessionId) return null
  const session = await prisma.session.findUnique({
    select: { userId: true },
    where: { id: sessionId, expirationDate: { gt: new Date() } },
  })
  if (!session?.userId) throw redirect('/', { headers: { 'set-cookie': await authSessionStorage.destroySession(...) } })
  return session.userId
}
```
