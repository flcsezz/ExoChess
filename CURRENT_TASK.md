# Current Task Board

## Active Task
- Status: in_progress
- Task ID: P1-T01
- Owner: opencode agent
- Started: 2026-03-24
- Finished: 2026-03-24
- Files changed: N/A (audit only)
- Verification run: audit completed - all impacted areas mapped
- Result: Complete - impact map documented in this file
- Blockers: None
- Next recommended task: P1-T02 (Remove watch/blog navigation)
  - `lib/src/tab_scaffold.dart`
  - `lib/src/view/home/home_tab_screen.dart`
  - `lib/src/view/watch/`
  - `lib/src/view/broadcast/`
  - `lib/src/view/play/`
  - `assets/images/`
  - `pubspec.yaml`
  - `android/app/src/main/AndroidManifest.xml`
  - `android/app/build.gradle.kts`
  - `ios/Runner.xcodeproj/project.pbxproj`
- Required verification:
  - confirm impacted areas are mapped before coding

## Audit Results

### WATCH/BROADCAST/BLOG - TO BE REMOVED

**Navigation Shell (tab_scaffold.dart):**
- Line 19-24: `BottomTab.watch` enum entry - REMOVE
- Line 15: Import `watch_tab_screen.dart` - REMOVE
- Line 67, 85, 100, 119: Watch-related providers/keys (watchNavigatorKey, watchScrollController, watchTabInteraction) - REMOVE
- Line 239-243: Watch tab builder in `_tabBuilder` - REMOVE

**Watch Views (lib/src/view/watch/):**
- `watch_tab_screen.dart` - REMOVE ENTIRELY
- `streamer_screen.dart` - REMOVE ENTIRELY
- `live_tv_channels_screen.dart` - REMOVE ENTIRELY
- `tv_screen.dart` - REMOVE ENTIRELY

**Broadcast Views (lib/src/view/broadcast/):**
- All 16 files - REMOVE ENTIRELY

**Home Tab (home_tab_screen.dart):**
- Line 14-15: Blog model imports - REMOVE
- Line 156-158: `featuredTournamentsProvider` usage (online only) - KEEP but handle offline
- Line 159-161: `blogCarouselProvider` usage - REMOVE
- Line 233-249: Blog carousel widget in phone layout - REMOVE
- Line 290-296: Blog carousel widget in tablet layout - REMOVE

**Related Models:**
- `lib/src/model/blog/` - REMOVE entire directory
- `lib/src/model/tournament/` - KEEP (used for featured tournaments UI)

### ONLINE PLAY - TO BE REMOVED (preserve local)

**Play Views (lib/src/view/play/):**
Files to REMOVE (online-only):
- `play_menu.dart` - has online play options
- `quick_game_matrix.dart` - online quick pairing
- `create_game_widget.dart` - online game creation
- `create_correspondence_game_bottom_sheet.dart` - online correspondence
- `playban.dart` - online playban
- `ongoing_games_screen.dart` - online games
- `challenge_odd_bots_screen.dart` - challenge bots online
- `create_challenge_bottom_sheet.dart` - create challenge
- `correspondence_challenges_screen.dart` - correspondence challenges
- `play_bottom_sheet.dart` - play options sheet
- `common_play_widgets.dart` - shared play widgets (review)
- `challenge_list_item.dart` - challenge UI
- `time_control_modal.dart` - time controls (may need for local)

**Lobby Models (lib/src/model/lobby/):**
- All 6 files are online-only - REMOVE

### BRANDING - TO BE REBRANDED

**App Bar Title:**
- `lib/src/widgets/misc.dart` lines 8-30: `AppBarLichessTitle` widget with "lichess.org" text - REPLACE

**Logo Assets:**
- `assets/images/logo-white.png` - REPLACE
- `assets/images/logo-transp.png` - REPLACE
- `assets/images/logo-black.png` - REPLACE

**Package Config:**
- `pubspec.yaml` line 1: `name: lichess_mobile` - RENAME to chessigma_mobile
- `pubspec.yaml` line 2: description - UPDATE

**Platform Config (need verification):**
- `android/app/build.gradle.kts` - Check for app name
- `android/app/src/main/AndroidManifest.xml` - Check for app name
- `ios/Runner.xcodeproj/project.pbxproj` - Check for app name

**User-Facing Strings (l10n):**
- `lib/l10n/l10n.dart` and locale files - 419 references to "lichess.org" in user strings - UPDATE
- Various other Lichess references in UI strings - UPDATE

### TO BE PRESERVED/KEEP

- `lib/src/view/play/` - OverTheBoardScreen (need to locate)
- `lib/src/view/puzzle/` - Puzzle screens
- `lib/src/view/learn/` - Learn screens
- `lib/src/view/more/` - More tab (except for branding)
- Cloud Stockfish / engine evaluation
- Offline correspondence games
- User authentication (for local user profile)

## Update Template
- Status:
- Task ID:
- Owner:
- Started:
- Finished:
- Files changed:
- Verification run:
- Result:
- Blockers:
- Next recommended task:

## Handoff Notes
- Phase 1 is planning and refactoring for feature removal plus Chessigma rebrand.
- Keep intact:
  - local over-the-board play with a friend
  - cloud Stockfish
  - puzzles
  - learn
  - any unspecified feature
- Remove:
  - online play
  - watch/broadcast
  - blog
  - Lichess logo/splash/user-visible branding
