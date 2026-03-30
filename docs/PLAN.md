# Chessigma Refactoring Plan

## Phase 1: Rebrand + Feature Removal (COMPLETED)

- **Goal:** Rebrand the app as Chessigma and remove online/watch/blog surfaces while keeping local play, puzzles, and learn stable.
- **Done:** Rebranded to Chessigma, removed navigation tabs, updated constants.

## Phase 2: Analysis Architecture (COMPLETED)

- **Goal:** Unify Stockfish and Fairy-Stockfish under a single `AnalysisController`.
- **Done:** Created `AnalysisController`, migrated local engine logic.

## Phase 3: UI Refresh (COMPLETED)

- **Goal:** Apply the new Chessigma design system to all screens.
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
- [x] `P6-T01` Fix opening explorer compatibility: `explorer.lichess.ovh` now requires OAuth auth (anti-DDoS). Fixed `ChessigmaClient.send()` to send raw OAuth token (not HMAC-signed bearer) to non-kLichessHost endpoints.
- [ ] `P6-T02` Integrate Lichess Cloud Evaluation API for instant, high-depth analysis.
- [x] `P6-T03` Redesign the Move Feedback widget to feature a persistent, chess.com-style animated icon without text labels.
- [ ] Remove legacy tests for removed features (Watch, Correspondence).
- [ ] Optimize engine performance on lower-end devices.
- [ ] Finalize ACPL thresholds for mate transitions.
