# ExoChess Refactoring Plan

## Phase 2: Analysis Architecture (COMPLETED)

- **Goal:** Unify Stockfish and Fairy-Stockfish under a single `AnalysisController`.
- **Done:** Created `AnalysisController`, migrated local engine logic.

## Phase 3: UI Refresh (COMPLETED)

- **Goal:** Apply the new ExoChess design system to all screens.
- **Done:** Updated colors, fonts, and spacing across the app. Note: Some legacy tests for removed features (like 'Watch') are currently failing and should be removed/updated in a future phase.

## Phase 4: Local Play Enhancements (COMPLETED)

- **Goal:** Improve the offline play experience with computer and over-the-board.
- **Done:** Added level selection, refined move animations.

## Phase 5: Analysis Board Intelligence (COMPLETED)

- **Goal:** Add deep evaluation feedback and move taxonomy to the analysis board.
- **Status:** COMPLETED
- [x] `P5-T01` Implementation of ACPL-based move feedback (Brilliant, Great, Best, etc.).
- [x] `P5-T02` Migration of the legacy move taxonomy to the new feedback model.
- [x] `P5-T03` Background Stockfish preload for immediate analysis on screen entry.
- [x] `P5-T04` UI indicators for engine warmup state.
- [x] `P5-T05` Fix mate evaluation logic and symbol collisions.
- [x] `P5-T06` Implement `AnalysisLoadingOverlay` and retry logic.
- [x] `P5-T07` Resolve evaluation jitter and badge clipping.
- [x] `P5-T08` Replace preload stub with real persistence contract.
- [x] `P5-T09` **[CLEANUP]** Completely removed Firebase (FCM, Crashlytics) and fixed branding/URL mismatches in tests.
- [x] `P5-T10` Final verification, smoke tests, and doc sync.

## Phase 6: Stability and Polish (PENDING)

- **Goal:** Resolve remaining test failures and optimize performance.
- [x] `P6-T01` Fix opening explorer compatibility: `explorer.lichess.ovh` now requires OAuth auth (anti-DDoS). Fixed `ExoChessClient.send()` to send raw OAuth token (not HMAC-signed bearer) to non-kLichessHost endpoints.
- [ ] `P6-T02` Integrate Lichess Cloud Evaluation API for instant, high-depth analysis.
- [x] `P6-T03` Redesign the Move Feedback widget to feature a persistent, chess.com-style animated icon without text labels.
- [ ] Remove legacy tests for removed features (Watch, Correspondence).
- [ ] Optimize engine performance on lower-end devices.
- [ ] Finalize ACPL thresholds for mate transitions.

## Phase 7: Onboarding Experience ✅ COMPLETE

- **Goal:** Deliver a one-time, skippable onboarding flow that collects the user's display name and tours the four key feature pillars of ExoChess (Play, Puzzles, Analysis, Learn/Explorer). Architecture is UI-agnostic — widget stubs are marked `TODO-UX` for the designer to style.
- **Plan:** See [`docs/plans/2026-03-31-onboarding-experience.md`](plans/2026-03-31-onboarding-experience.md)
- **Decisions locked:**
  - Skip → name = `null`, home greets with "Welcome, User!"
  - Learn slide shows inline disclaimer: "Opening Explorer requires Lichess sign-in"
  - Settings gets a "Replay app tour" reset button
- [ ] `OB-T01` Add `onboarding` to `PrefCategory` enum in `preferences_storage.dart`
- [ ] `OB-T02` Create `OnboardingPrefs` model + `OnboardingNotifier` (`lib/src/model/onboarding/onboarding_preferences.dart`)
- [ ] `OB-T03` Run `dart run build_runner build` to generate `.freezed.dart` and `.g.dart` ted)
- [ ] `OB-T08` Wire `_AppRouter` navigation guard into `app.dart` (`Application.build()`)
- [ ] `OB-T09` Verify: `flutter analyze` — zero errors
- [ ] `OB-T10` Verify: first launch → onboarding; subsequent launches → `MainTabScaffold` directly
- [ ] `OB-T11` Mark complete in `PLAN.md` + update `CURRENT_TASK.md`
- [ ] `OB-T12`files
- [ ] `OB-T04` Create `OnboardingScreen` with `PageController` scaffolding (`lib/src/view/onboarding/onboarding_screen.dart`)
- [ ] `OB-T05` Create stub `WelcomePage` (name input + Next)
- [ ] `OB-T06` Create stub `FeaturePage` template (icon + title + body + Next) — 4 instances covering Play, Puzzles, Analysis, Learn; Learn slide includes Lichess disclaimer banner stub
- [ ] `OB-T07` Create stub `FinishPage` (personalised CTA: "Welcome, {name ?? 'User'}!" + Get Star Add "Replay app tour" button to Settings screen (`more_tab_screen.dart`) that resets `OnboardingPrefs.hasCompleted`

## Phase 8: Lichess Online Play (PENDING)

- **Goal:** Enable real Lichess online play for ExoChess users via OAuth 2.0 PKCE — allowing any Lichess user to sign into the app with their own account and access real-time matchmaking, correspondence, challenges, and the Opening Explorer.
- **Plan:** See [`docs/plans/2026-03-31-lichess-online-play.md`](plans/2026-03-31-lichess-online-play.md)
- **Context:** The codebase already has 100% of the infrastructure (OAuth PKCE, WebSocket, lobby, game services). The only blocker was the wrong `client_id`. The OAuth app is now registered on Lichess and the `client_id` is known.
- **⚠️ Security:** NEVER commit the OAuth token or any secret to source control. Use `--dart-define` or environment variables only.
- [ ] `P8-T01` Register OAuth app at `lichess.org/account/oauth/app` and obtain a `client_id` → **DONE** (app registered)
- [ ] `P8-T02` Update `kExoChessClientId` in `lib/src/constants.dart` to the registered `client_id`
- [ ] `P8-T03` Smoke-test sign-in flow end-to-end: OAuth → token exchange → `/api/account` → user displayed
- [ ] `P8-T04` Verify Opening Explorer works when signed in (uses `explorer.lichess.ovh` with Bearer token)
- [ ] `P8-T05` Audit which removed tabs/features (lobby, real-time games, correspondence) to restore vs keep hidden
- [ ] `P8-T06` Restore Lichess sign-in entry point in the More/Settings tab UI
- [ ] `P8-T07` End-to-end test: sign in → find game → play → sign out
- [ ] `P8-T08` Mark complete in `PLAN.md` + update `CURRENT_TASK.md`
