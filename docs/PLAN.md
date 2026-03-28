# Chessigma Refactoring Plan

## Phase 1: Rebrand + Feature Removal (COMPLETED)

**Goal:** Transform the app into Chessigma by removing online multiplayer, watch, and blog features while stabilizing local play, puzzles, and learn.

### Summary of Achievements

- **Online Features Removed:** Watch tab, Blog carousel, and all online multiplayer entry points (Tournaments, Lobby, Challenges) are gone.
- **Implementation Purged:** Broadcast, TV, and Streamer implementation paths and models have been deleted.
- **Rebranding:** App renamed to "Chessigma Mobile" globally. All visible Lichess branding, logos, and splash assets replaced.
- **Platform Metadata:** Android `applicationId`, iOS `PRODUCT_BUNDLE_IDENTIFIER`, and package names updated.
- **Stability:** Core local gameplay (Over the Board, vs Computer), Puzzles, and Learn features verified stable and functional.
- **Code Health:** `flutter analyze` passing with zero errors/warnings.

## Phase 2: External Game History + Review Entry (COMPLETED)

**Goal:** Let the user enter a Chess.com or Lichess username, fetch public game history from that source, show a selectable history list inside Chessigma, and open any selected game in the existing review/analysis flow. PGN import must also continue to open review using the same analysis path.

### Summary of Achievements

- **Source Support:** Fully implemented fetchers for Lichess.org and Chess.com public game histories.
- **Backend integration:** Chess.com archives API integration complete.
- **Unified UI:** Created `ExternalGameFetchWidget` on the home screen for streamlined access to Lichess, Chess.com, and PGN imports.
- **Seamless Review:** Fetching or importing games automatically routes them to the existing high-quality Analysis/Review flow.
- **Visual Polish:** Updated color palette to deep dark theme with elegant gold accents.
- **Branding:** App-wide logo replacement and home screen icon updated.
- **Splash:** Removed staggered animations and delays for instant-ready app feel.

### Phase 2 Tasks

- [x] `P2-T01` Review-path audit and source contract.
- [x] `P2-T02` Define external history domain models and provider boundaries.
- [x] `P2-T03` Implement Lichess public-history fetcher.
- [x] `P2-T04` Implement Chess.com public-history fetcher.
- [x] `P2-T05` Build source + username entry UI.
- [x] `P2-T06` Build external game-history list UI.
- [x] `P2-T07` Wire external game selection into review.
- [x] `P2-T08` Consolidate PGN import and external review entry.
- [x] `P2-T09` Add caching, rate-limit handling, and failure states.
- [x] `P2-T10` Tests and verification.

### Phase 2 Dependencies

- `P2-T01` completed before implementation work.
- `P2-T02` before `P2-T03` and `P2-T04`.
- `P2-T03` and `P2-T04` can run in parallel after the shared model contract is settled.
- `P2-T05` and `P2-T06` can start once the provider contracts are stable.
- `P2-T07` after at least one source is returning real normalized game data.
- `P2-T08` after `P2-T07`.
- `P2-T09` and `P2-T10` last.

### P2-T01 Audit Notes

#### Current Review Entry Paths

- `lib/src/view/more/import_pgn_screen.dart`
  - `ImportPgnScreen.handlePgnText` parses clipboard/file text with `PgnGame.parseMultiGamePgn`.
  - Single-game import opens `AnalysisScreen.buildRoute(... AnalysisOptions.pgn(...))`.
  - Multi-game import routes to `PgnGamesListScreen`.
- `lib/src/view/analysis/pgn_games_list_screen.dart`
  - Each selected PGN game opens `AnalysisScreen.buildRoute(... AnalysisOptions.pgn(...))`.
  - Current behavior hardcodes `orientation: Side.white`, `isComputerAnalysisAllowed: true`, and starts at move 1 when moves exist.
- `lib/src/view/user/game_history_screen.dart`
  - Internal Chessigma/Lichess-backed history opens review through `AnalysisOptions.archivedGame`.
  - This path depends on a server-resolvable `gameId`, not self-contained PGN.
- `lib/src/model/game/game_history.dart`
  - Internal history is tightly coupled to `GameRepository.getUserGames(...)` and local `gameStorageProvider`.
  - It is not a good direct reuse point for external source integration without introducing a source-agnostic layer.
- `lib/src/model/analysis/analysis_controller.dart`
  - `AnalysisOptions.pgn` already supports self-contained review for any PGN string plus variant/orientation/computer-analysis flag.
  - `AnalysisOptions.archivedGame` is server-backed and loads by `gameId` through `archivedGameProvider`.

#### Source Contract Decision

- Phase 2 external history must hand selected games into review through `AnalysisOptions.pgn`.
- Do not add a new external `archivedGame` mode in Phase 2.
- Rationale:
  - external games from Chess.com/Lichess public history are naturally fetchable as PGN or PGN-equivalent records
  - `AnalysisOptions.pgn` already powers imported-game review successfully
  - this avoids coupling external review to Chessigma server IDs or internal repository assumptions
  - this keeps PGN import and external-history review on one code path

#### Design Consequences For Phase 2

- `P2-T02` should create normalized external-history items that include:
  - source (`lichess` or `chesscom`)
  - username
  - stable external game identifier or URL
  - display metadata for list rows
  - full PGN string for review handoff, or enough fetch metadata to obtain it before opening review
  - preferred orientation if derivable from the username and PGN headers
- `P2-T06` should reuse UI ideas from `GameHistoryScreen`, but not `userGameHistoryProvider` directly.
- `P2-T07` should centralize a single helper that converts an external-history item into `AnalysisOptions.pgn`.
- `P2-T08` should align imported-PGN and external-history handoff behavior:
  - same move-cursor rule
  - same computer-analysis allowance rule
  - same orientation derivation rule where possible

### Suggested Agent Ownership

- Agent A: shared domain model + provider boundaries.
- Agent B: Lichess history integration.
- Agent C: Chess.com history integration.
- Agent D: entry UI, history list UI, and review handoff.
- Agent E: tests, caching, and failure-state cleanup.

### Done When

- [x] User can choose `Lichess` or `Chess.com`.
- [x] User can enter a username and load public game history.
- [x] User can pick any loaded game and open review in the existing analysis flow.
- [x] PGN import still works for single-game and multi-game review.
- [x] Error states for missing usernames, network failures, and upstream rate limits are handled cleanly.
- [x] Validation passes or blockers are recorded in `CURRENT_TASK.md`.

## Phase 3: Frontend Overhaul (IN PROGRESS)

**Goal:** Completely redesign the app's frontend using the Stitch "Luminous Grandmaster" design system and "Cyberpunk UI" guidelines. The app must be aesthetically pleasing, premium, and utilize glassmorphism, neon glows, and immersive dark mode layouts.

### Phase 3 Tasks

- [x] `P3-T01` Implement Core Design System (ThemeData, Colors, Typography).
- [x] `P3-T02` Build Reusable UI Widgets (GlassCard, NeonButton, PulseChip).
- [x] `P3-T03` Redesign Home Screen & Navigation.
- [x] `P3-T04` Redesign Game Features & Play Menu.
- [x] `P3-T05` Redesign History & Analysis Screens.
- [x] `P3-T06` Redesign Settings & Profile Screens.
- [x] `P3-T07` UI/UX Polish and Verification.

### Done When
- [x] The app uses the deep void background and Neon/Glassmorphism styling.
- [x] Home, Play, History, and Settings screens are fully updated.
- [x] Dark mode contrast standards (4.5:1 minimum) are met.

## Phase 4: External History & Review Fixes (IN PROGRESS)

**Goal:** Fix bugs in external game history sorting, icon colors, and review board orientation.

### Phase 4 Tasks

- [x] `P4-T01` Fix Lichess date parsing and ensure global sorting in providers.
- [x] `P4-T02` Fix Chess.com orientation by improving name matching or using API metadata.
- [x] `P4-T03` Fix win/loss/draw icon logic in history tiles.
- [x] `P4-T04` Verify fixes across all sources (Lichess, Chess.com, PGN).

### Done When

- [x] Lichess and Chess.com games are sorted most recent first.
- [x] Chess.com game results show correct colors (Win: Green, Loss: Red, Draw: Grey).
- [x] Board orientation in review automatically favors the fetched user's side.
- [x] `flutter analyze` passes.
