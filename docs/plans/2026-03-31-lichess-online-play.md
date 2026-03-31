# Phase 8: Lichess Online Play

## Approach

The ExoChess codebase is a fork of the official Lichess mobile app and already contains
100% of the infrastructure needed for online play — OAuth 2.0 PKCE, WebSocket connections,
lobby, real-time game, correspondence, and challenge services. The only thing preventing
it from working was using the wrong OAuth `client_id`.

This phase wires up a real registered Lichess OAuth application so that **any Lichess user**
can sign into ExoChess with their own account and play online.

---

## ⚠️ Critical Security Notes

> **The Personal Access Token (PAT) shared in chat is a private secret
> tied to a single Lichess account. Treat it as a password.**
>
> - **Revoke it immediately at https://lichess.org/account/oauth if it was shared accidentally.**
> - **NEVER put any token or secret into source code or commit it to git.**
> - Use `--dart-define=LICHESS_CLIENT_ID=yourvalue` at build time for configuration.

---

## PAT vs OAuth App — Important Distinction

| | Personal Access Token (PAT) | OAuth 2.0 PKCE App |
|-|-|-|
| **What it is** | Static key for one specific account | App registration that lets ANY user sign in |
| **URL to create** | `lichess.org/account/oauth/token` | `lichess.org/account/oauth/app` |
| **Good for** | Server-side scripts, testing your own account | Mobile apps with user sign-in |
| **What we need** | ❌ Not for this feature | ✅ This is what we need |

The PAT you shared is useful for **testing** (e.g., manually verifying the Opening Explorer
works when authorised), but the app needs a registered OAuth **client_id** so that your
users can log in with their own accounts.

---

## What Need To Do To Register The OAuth App

1. Go to **https://lichess.org/account/oauth/app**
2. Click **"New application"**
3. Fill in:
   - **Name:** `ExoChess`
   - **Redirect URI:** `org.exochess.mobile://login-callback`  
     _(this exactly matches `kOAuthRedirectUri` and `kOAuthRedirectUriScheme` in the codebase)_
   - **Scopes:** `web:mobile` _(already set in `oauthScopes` list)_
4. Save → Lichess gives you a **`client_id`** string (e.g. `exochess.mobile`)
5. That string goes into `kExoChessClientId` in `constants.dart`

---

## Code Change Required

### [`lib/src/constants.dart`](file:///home/flcsezz/mobile/lib/src/constants.dart)

```dart
// BEFORE (uses official Lichess app's ID — will fail for third-party apps):
const kExoChessClientId = 'lichess_mobile';

// AFTER (your registered OAuth app client_id from lichess.org/account/oauth/app):
const kExoChessClientId = String.fromEnvironment(
  'LICHESS_CLIENT_ID',
  defaultValue: 'exochess',   // ← replace with your actual client_id
);
```

Using `String.fromEnvironment` means the ID can be overridden at build time without
touching source code:
```bash
flutter run --dart-define=LICHESS_CLIENT_ID=your.actual.client.id
```

---

## What Online Features Unlock After This Change

Because this is a Lichess fork, the following features are **already wired up** in the codebase
but currently non-functional without valid auth:

| Feature | Status | Notes |
|---------|--------|-------|
| Lichess sign-in / sign-out | ✅ Implemented | Just needs correct `client_id` |
| Opening Explorer (`explorer.lichess.ovh`) | ✅ Fixed (P6-T01) | Works the moment user is signed in |
| Lichess Cloud Evaluation | ⏳ Planned (P6-T02) | Needs sign-in to be active |
| Real-time online games (lobby) | 🔧 Code exists, tab removed in Phase 1 | Needs UI restoration decision |
| Correspondence games | 🔧 Service exists | Needs UI restoration decision |
| Challenges | 🔧 Service exists | Needs UI restoration decision |
| User profile / rating | ✅ Exists in More tab | Works once signed in |

---

## Decisions Needed (P8-T05)

When auditing what to restore, the key question is which tabs/surfaces to bring back.
The original Phase 1 deliberately removed them to "keep local play, puzzles, and learn stable."
Now that we're ready to go online, here are the options:

| Surface | Recommendation |
|---------|---------------|
| **Lobby / Find a game** | ✅ Restore — core value of online play |
| **Real-time game board** | ✅ Restore — already exists, just not reachable |
| **Correspondence** | ⏳ Defer to Phase 9 — adds complexity |
| **Watch / Broadcasts** | ⏳ Defer — not related to play |
| **Challenge a friend** | ✅ Restore — low cost, high value |

---

## Action Items

- [ ] `P8-T01` Register OAuth app at `lichess.org/account/oauth/app` — get `client_id` → **DONE** (pending client_id)
- [ ] `P8-T02` Update `kExoChessClientId` in `constants.dart` (use `String.fromEnvironment`, never hardcode secrets)
- [ ] `P8-T03` Smoke-test sign-in flow: OAuth PKCE → token exchange → `/api/account` → user shown in More tab
- [ ] `P8-T04` Verify Opening Explorer works when signed in
- [ ] `P8-T05` Audit and decide which removed features to restore (lobby, challenges, correspondence)
- [ ] `P8-T06` Restore Lichess sign-in entry point in More tab (currently hidden or removed in Phase 1)
- [ ] `P8-T07` End-to-end test: sign in → lobby → find game → play a game → sign out
- [ ] `P8-T08` Mark complete in `PLAN.md` + update `CURRENT_TASK.md`

---

## Verification Plan

### Automated
```bash
flutter analyze
flutter test
```

### Manual (requires Lichess test account)
1. Cold-launch app → tap sign in → browser opens `lichess.org/oauth`
2. Authorise → app receives callback → user profile appears in More tab
3. Open Explorer slide → Opening Explorer loads real data
4. Navigate to home → lobby loads games
5. Challenge bot → game starts, moves register on `lichess.org`
6. Sign out → app returns to anonymous state

---

## Security Checklist

- [ ] No token or secret is hardcoded in any `.dart` file
- [ ] `constants.dart` uses `String.fromEnvironment` for `client_id`
- [ ] `.gitignore` has any local `.env` or `--dart-define` files excluded
- [ ] The PAT shared in chat has been **revoked** at `lichess.org/account/oauth`
