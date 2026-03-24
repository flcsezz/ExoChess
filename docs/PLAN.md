# Phase 1 Refactoring Plan: Chessigma Rebrand + Feature Removal

## Goal
Remove online multiplayer, watch, and blog surfaces from this app while rebranding user-visible Lichess branding to Chessigma, without breaking local play, cloud Stockfish, puzzles, learn, or any untouched feature.

## Scope
- Remove online play entry points and flows.
- Remove watch/broadcast/blog entry points and flows.
- Replace Lichess user-facing branding, logos, and splash assets with Chessigma.
- Keep over-the-board local play, cloud analysis/Stockfish, puzzles, learn, and all unspecified features working.

## Guardrails
- Do not change behavior outside the requested scope.
- Prefer removing UI entry points first, then dead routes/providers, then stale assets/docs.
- Treat internal identifiers with care. User-facing branding changes are required in Phase 1; risky namespace/package renames must only happen if they are externally visible or required for build/runtime correctness.
- Every task must leave the repo in a buildable/testable state.

## Phase 1 Tasks
- [ ] `P1-T01` Repo audit and impact map. Inventory all files tied to online play, watch/broadcast/blog, and user-visible Lichess branding. Start with `lib/src/tab_scaffold.dart`, `lib/src/view/home/home_tab_screen.dart`, `lib/src/view/watch/`, `lib/src/view/broadcast/`, `lib/src/view/play/`, `assets/images/`, `pubspec.yaml`, `android/app/src/main/AndroidManifest.xml`, `android/app/build.gradle.kts`, and `ios/Runner.xcodeproj/project.pbxproj`. → Verify: `docs/PLAN.md` notes/tasks stay aligned with real file ownership before code changes begin.
- [ ] `P1-T02` Remove watch/blog navigation surfaces. Remove the Watch tab and any home-screen/blog entry points without touching puzzles, learn, more, or local-play access. Primary files likely include `lib/src/tab_scaffold.dart`, `lib/src/view/watch/`, `lib/src/view/home/home_tab_screen.dart`, and `lib/src/view/home/blog_carousel.dart`. → Verify: app navigation still exposes Home, Puzzles, Learn, More, and no Watch/Blog entry remains.
- [ ] `P1-T03` Remove watch/broadcast implementation paths. Delete or disconnect broadcast, TV, streamers, and related routes/providers once no live navigation depends on them. Primary targets likely include `lib/src/view/watch/`, `lib/src/view/broadcast/`, and related model/provider imports. → Verify: `flutter analyze` shows no dead imports or unresolved references from watch/broadcast removal.
- [ ] `P1-T04` Remove online multiplayer entry points while preserving local friend play. Strip lobby/challenge/correspondence/tournament access from UI and flows, but keep `OverTheBoardScreen`, offline computer, puzzles, learn, and cloud analysis intact. Primary targets likely include `lib/src/view/play/`, `lib/src/model/lobby/`, challenge-related game loading, and home quick-pairing widgets. → Verify: user can still launch local over-the-board play and offline computer play; no online play entry point remains.
- [ ] `P1-T05` Stabilize retained gameplay paths. Clean up any shared code that assumed online features exist, especially around game sources, providers, empty states, and home sections. → Verify: retained screens open without null-state crashes or orphaned buttons.
- [ ] `P1-T06` Rebrand app assets and visible brand strings to Chessigma. Replace logo assets, splash assets, app title text, visible brand components, and user-facing documentation strings that should no longer say Lichess. Primary targets likely include `assets/images/logo-*`, `pubspec.yaml`, app bars/titles, README, and platform display names. → Verify: app launch, splash, top-level titles, and visible docs show Chessigma branding.
- [ ] `P1-T07` Rebrand platform/app metadata safely. Update Android/iOS app display branding and externally visible identifiers as needed, including manifest host/app name review and splash configuration. Primary targets likely include `android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml`, `android/app/src/main/kotlin/.../MainActivity.kt`, `ios/Runner.xcodeproj/project.pbxproj`, and generated splash configuration in `pubspec.yaml`. → Verify: project still builds, app name is Chessigma on device, and no broken deep-link/splash config remains.
- [ ] `P1-T08` Update tests, fixtures, and docs for the new scope. Remove or rewrite tests that assert watch/broadcast/blog/online multiplayer behavior, and keep tests for retained features intact. Update docs to reflect Chessigma and the reduced feature set. → Verify: tests no longer reference removed routes/features unless explicitly kept.
- [ ] `P1-T09` Final verification sweep. Run the smallest relevant validation set for this refactor: `dart run build_runner build --delete-conflicting-outputs`, `flutter analyze`, and targeted `flutter test`/full `flutter test` depending on failures encountered. Manually smoke-check navigation for Home, Puzzles, Learn, More, local over-the-board play, offline computer, and cloud analysis/puzzles/learn. → Verify: no analyzer errors, tests pass or documented blockers exist, and retained features work.

## Task Dependencies
- `P1-T01` before all implementation tasks.
- `P1-T02` before `P1-T03`.
- `P1-T04` can run in parallel with `P1-T02` after `P1-T01` if file ownership does not overlap.
- `P1-T05` after `P1-T03` and `P1-T04`.
- `P1-T06` and `P1-T07` after the removal tasks stop moving navigation/app-shell code.
- `P1-T08` after implementation tasks settle.
- `P1-T09` last.

## Suggested Agent Ownership
- Agent A: navigation shell + home/watch/blog removal.
- Agent B: online play flow removal while preserving over-the-board/local paths.
- Agent C: branding/assets/platform metadata.
- Agent D: tests/docs/final verification after feature work lands.

## Done When
- [ ] No Watch tab, broadcast, streamers, or blog UI remains.
- [ ] No online multiplayer/challenge/correspondence/tournament play entry remains.
- [ ] Local friend play still works.
- [ ] Cloud Stockfish, puzzles, and learn still work.
- [ ] User-visible Lichess branding is replaced with Chessigma.
- [ ] Validation passes or any blocker is written down explicitly in `CURRENT_TASK.md`.
