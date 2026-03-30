# Analysis Board Intelligence Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make analysis feel instant and informative by preloading Stockfish as soon as a game opens, caching the result, and surfacing move-quality feedback directly on the board and move list.

**Architecture:** The analysis screen should own three separate layers: a pure analysis-result model, a preload/cache service that starts as soon as a game is opened, and a UI annotation layer that renders badges/icons on the moved piece and move list. Keep the data contract source-agnostic so imported PGNs, external history, and future sources all flow through the same path. Loading state must be explicit so the board can render immediately even if the first engine pass is not ready.

**Tech Stack:** Flutter, current analysis controller/state, existing board widgets, Stockfish integration, existing storage/cache helpers.

---

### Task 1: Define the analysis feedback contract

**Files:**
- Create: `lib/src/model/analysis/analysis_feedback.dart`
- Modify: `lib/src/model/analysis/analysis_controller.dart`
- Test: `test/src/model/analysis/analysis_feedback_test.dart`

**Step 1: Write the failing test**

Cover the move-quality mapping and the icon/badge contract first. The test should prove that the model can classify best, great, good, inaccuracy, mistake, and blunder without any UI code.

**Step 2: Run the test to verify it fails**

Run: `flutter test test/src/model/analysis/analysis_feedback_test.dart`
Expected: FAIL because the new contract does not exist yet.

**Step 3: Write the minimal implementation**

Create a small immutable model that exposes the move label, severity, and display badge key needed by the board and move list.

**Step 4: Run the test to verify it passes**

Run: `flutter test test/src/model/analysis/analysis_feedback_test.dart`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/src/model/analysis/analysis_feedback.dart lib/src/model/analysis/analysis_controller.dart test/src/model/analysis/analysis_feedback_test.dart
git commit -m "feat: add analysis feedback contract"
```

### Task 2: Add preload and cache warmup

**Files:**
- Create: `lib/src/model/analysis/analysis_preload_service.dart`
- Modify: `lib/src/model/analysis/analysis_controller.dart`
- Test: `test/src/model/analysis/analysis_preload_service_test.dart`

**Step 1: Write the failing test**

Verify that opening a game starts background analysis and that the cache key prevents duplicate work for the same game.

**Step 2: Run the test to verify it fails**

Run: `flutter test test/src/model/analysis/analysis_preload_service_test.dart`
Expected: FAIL because no preload service exists yet.

**Step 3: Write the minimal implementation**

Add a warmup service that can kick off analysis early, reuse cached results, and expose an in-flight/loading state.

**Step 4: Run the test to verify it passes**

Run: `flutter test test/src/model/analysis/analysis_preload_service_test.dart`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/src/model/analysis/analysis_preload_service.dart lib/src/model/analysis/analysis_controller.dart test/src/model/analysis/analysis_preload_service_test.dart
git commit -m "feat: preload analysis when opening review"
```

### Task 3: Render board badges and move list markers

**Files:**
- Create: `lib/src/view/analysis/widgets/analysis_feedback_badge.dart`
- Modify: `lib/src/view/analysis/analysis_screen.dart`
- Modify: `lib/src/view/analysis/widgets/analysis_board.dart`
- Test: `test/src/view/analysis/analysis_feedback_badge_test.dart`

**Step 1: Write the failing test**

Verify that the board can display the correct badge/icon for a moved piece and that move-list labels stay in sync with the model.

**Step 2: Run the test to verify it fails**

Run: `flutter test test/src/view/analysis/analysis_feedback_badge_test.dart`
Expected: FAIL because the badge widget and bindings do not exist yet.

**Step 3: Write the minimal implementation**

Add a small reusable badge widget and wire it into the board rendering path without changing how moves are generated.

**Step 4: Run the test to verify it passes**

Run: `flutter test test/src/view/analysis/analysis_feedback_badge_test.dart`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/src/view/analysis/widgets/analysis_feedback_badge.dart lib/src/view/analysis/analysis_screen.dart lib/src/view/analysis/widgets/analysis_board.dart test/src/view/analysis/analysis_feedback_badge_test.dart
git commit -m "feat: show analysis feedback on board"
```

### Task 4: Add loading, empty, error, and retry states

**Files:**
- Create: `lib/src/view/analysis/widgets/analysis_loading_overlay.dart`
- Modify: `lib/src/view/analysis/analysis_screen.dart`
- Test: `test/src/view/analysis/analysis_loading_overlay_test.dart`

**Step 1: Write the failing test**

Verify that a game opening with cold analysis shows a loading state, and that failures can be retried without leaving the analysis screen.

**Step 2: Run the test to verify it fails**

Run: `flutter test test/src/view/analysis/analysis_loading_overlay_test.dart`
Expected: FAIL because the loading overlay does not exist yet.

**Step 3: Write the minimal implementation**

Add an overlay that explains the engine warmup and keeps the board interactive while analysis is in progress.

**Step 4: Run the test to verify it passes**

Run: `flutter test test/src/view/analysis/analysis_loading_overlay_test.dart`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/src/view/analysis/widgets/analysis_loading_overlay.dart lib/src/view/analysis/analysis_screen.dart test/src/view/analysis/analysis_loading_overlay_test.dart
git commit -m "feat: add analysis loading state"
```

### Task 5: Verification and rollout

**Files:**
- Modify: `docs/PLAN.md`
- Modify: `CURRENT_TASK.md`
- Modify: `docs/New_features.md`
- Test: `flutter analyze`

**Step 1: Run the full verification**

Run: `flutter analyze`
Expected: PASS with zero errors and warnings.

**Step 2: Run the targeted tests**

Run:

```bash
flutter test test/src/model/analysis/analysis_feedback_test.dart
flutter test test/src/model/analysis/analysis_preload_service_test.dart
flutter test test/src/view/analysis/analysis_feedback_badge_test.dart
flutter test test/src/view/analysis/analysis_loading_overlay_test.dart
```

Expected: PASS.

**Step 3: Sync the docs**

Update `docs/PLAN.md`, `CURRENT_TASK.md`, and `docs/New_features.md` with the shipped behavior and any follow-up ideas that were intentionally left out of scope.

**Step 4: Commit**

```bash
git add docs/PLAN.md CURRENT_TASK.md docs/New_features.md
git commit -m "docs: finalize analysis board intelligence plan"
```
