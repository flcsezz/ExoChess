# Onboarding Experience — ExoChess

## Approach

Implement a one-time, skippable onboarding flow that launches immediately after the
native splash fades in (before the main `MainTabScaffold`). The flow collects the
user's display name, then walks them through the four key feature pillars of ExoChess
via a swipeable, animated page-view. Completion state is persisted in
`SharedPreferences` so the flow is shown exactly once.

Because the UI/UX design will be handled separately, this plan focuses exclusively on
**architecture, data contracts, navigation wiring, and content mapping**. Widgets are
stubbed with clear `TODO-UX` markers so the designer can drop in real visuals without
touching the logic layer.

---

## Scope

### In

- `OnboardingPrefs` data model + `PrefCategory` entry
- `OnboardingNotifier` (Riverpod `NotifierProvider`)
- `OnboardingScreen` widget (page-view scaffold + controller logic)
  - Page 0 — Welcome + name input
  - Page 1-4 — Feature tour slides
  - Page 5 — "You're ready!" CTA
- Navigation guard in `app.dart` (`Application._redirectIfNeeded`)
- Stub widgets for each page with `TODO-UX` comments
- Plan entry in `PLAN.md` (Phase 7)
- `CURRENT_TASK.md` update

### Out

- Visual polish / final UI (handled by UI/UX collaborator)
- Localization strings (add keys, but translations deferred)
- Analytics / tracking events
- Account/Lichess login prompt during onboarding

---

## Feature Tour Content Map

| Slide | Feature                      | Key Points                                                                                                       | Icon/Asset hint                     |
| ----- | ---------------------------- | ---------------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| 1     | **Play** — OTB & vs Computer | "Play against the AI at any level, or pass-and-play with a friend over the board."                               | `Symbols.chess_pawn` or board image |
| 2     | **Puzzles**                  | "Train your tactics with thousands of rated puzzles sourced from real games."                                    | `Symbols.extension_rounded`         |
| 3     | **Analysis Board**           | "Review any game with live Stockfish evaluation, move quality badges (Brilliant → Blunder), and CP-loss charts." | `Symbols.query_stats`               |
| 4     | **Learn & Opening Explorer** | "Study openings interactively with the ChessDB explorer and master coordinate training."                         | `Symbols.school_rounded`            |

---

## Architecture

### New Files

```
lib/src/model/onboarding/
  onboarding_preferences.dart          # OnboardingPrefs + Notifier
  onboarding_preferences.freezed.dart  # (generated)
  onboarding_preferences.g.dart        # (generated)

lib/src/view/onboarding/
  onboarding_screen.dart               # Root page-view widget
  pages/
    welcome_page.dart                  # Step 0: name input
    feature_page.dart                  # Generic slide template (steps 1-4)
    finish_page.dart                   # Step 5: CTA
```

### Modified Files

| File                                              | Change                                                                                                                                      |
| ------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| `lib/src/model/settings/preferences_storage.dart` | Add `onboarding` to `PrefCategory` enum                                                                                                     |
| `lib/src/app.dart`                                | Replace `home: const MainTabScaffold()` with `home: const _AppRouter()` that redirects to onboarding when `hasCompletedOnboarding == false` |

---

## Data Contract

```dart
// onboarding_preferences.dart

@Freezed(fromJson: true, toJson: true)
sealed class OnboardingPrefs with _$OnboardingPrefs implements Serializable {
  const factory OnboardingPrefs({
    /// Whether the user has completed or skipped onboarding.
    @Default(false) bool hasCompleted,

    /// The display/pet name the user entered. Null if skipped.
    String? displayName,
  }) = _OnboardingPrefs;

  static const defaults = OnboardingPrefs();

  factory OnboardingPrefs.fromJson(Map<String, dynamic> json) =>
      _$OnboardingPrefsFromJson(json);
}

final onboardingPreferencesProvider =
    NotifierProvider<OnboardingNotifier, OnboardingPrefs>(
  OnboardingNotifier.new,
);

class OnboardingNotifier extends Notifier<OnboardingPrefs>
    with PreferencesStorage<OnboardingPrefs> {
  @override
  final prefCategory = PrefCategory.onboarding;

  @override
  OnboardingPrefs get defaults => OnboardingPrefs.defaults;

  @override
  OnboardingPrefs fromJson(Map<String, dynamic> json) =>
      OnboardingPrefs.fromJson(json);

  @override
  OnboardingPrefs build() => fetch();

  Future<void> complete({String? displayName}) =>
      save(state.copyWith(hasCompleted: true, displayName: displayName));

  Future<void> skip() => save(state.copyWith(hasCompleted: true));
}
```

---

## Navigation Logic (app.dart)

Replace:

```dart
home: const MainTabScaffold(),
```

With:

```dart
home: const _AppRouter(),
```

New widget:

```dart
class _AppRouter extends ConsumerWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingPreferencesProvider);
    if (!onboarding.hasCompleted) {
      return const OnboardingScreen();
    }
    return const MainTabScaffold();
  }
}
```

When the user finishes or skips onboarding:

```dart
await ref.read(onboardingPreferencesProvider.notifier).complete(displayName: name);
// Navigation is automatic because _AppRouter reacts to the provider change.
```

---

## `OnboardingScreen` Skeleton

```dart
class OnboardingScreen extends ConsumerStatefulWidget { ... }

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  final _nameController = TextEditingController();
  int _currentPage = 0;

  static const _totalPages = 6; // welcome + 4 features + finish

  void _next() { /* animate to next page */ }
  void _skip() { /* call notifier.skip() */ }
  void _finish() { /* call notifier.complete(displayName: _nameController.text.trim()) */ }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // controlled programmatically
            children: [
              WelcomePage(nameController: _nameController, onNext: _next),
              FeaturePage(slide: _slides[0], onNext: _next),
              FeaturePage(slide: _slides[1], onNext: _next),
              FeaturePage(slide: _slides[2], onNext: _next),
              FeaturePage(slide: _slides[3], onNext: _next),
              FinishPage(displayName: _nameController.text, onFinish: _finish),
            ],
          ),
          // TODO-UX: Page indicator dots
          // TODO-UX: Skip button (top-right)
          // TODO-UX: Progress bar
        ],
      ),
    );
  }
}
```

---

## Action Items

- [ ] `OB-T01` Add `onboarding` to `PrefCategory` enum in `preferences_storage.dart`
- [ ] `OB-T02` Create `OnboardingPrefs` model + `OnboardingNotifier` in `lib/src/model/onboarding/onboarding_preferences.dart`
- [ ] `OB-T03` Run `dart run build_runner build --delete-conflicting-outputs` to generate `.freezed.dart` and `.g.dart`
- [ ] `OB-T04` Create `OnboardingScreen` with `PageController` scaffolding in `lib/src/view/onboarding/onboarding_screen.dart`
- [ ] `OB-T05` Create stub `WelcomePage` (name `TextField` + Next button) with `TODO-UX` comments
- [ ] `OB-T06` Create stub `FeaturePage` (icon + title + body + Next button) with `TODO-UX` comments
- [ ] `OB-T07` Create stub `FinishPage` (personalised "Welcome, {name}!" + Get Started CTA) with `TODO-UX` comments
- [ ] `OB-T08` Wire navigation guard `_AppRouter` into `Application.build()` in `app.dart`
- [ ] `OB-T09` Verify: run `flutter analyze` — zero errors
- [ ] `OB-T10` Verify: first launch shows onboarding; reopening the app after completion shows `MainTabScaffold` directly
- [ ] `OB-T11` Mark tasks complete in `PLAN.md` and update `CURRENT_TASK.md`

---

## Resolved Decisions

| # | Decision | Resolution |
|---|----------|------------|
| 1 | **Skip behaviour** | Name stays `null`. Home screen shows **"Welcome, User!"** (or localised equivalent). No re-prompt anywhere. |
| 2 | **Opening Explorer / Lichess login** | Slide 4 (Learn/Explorer) shows an **inline disclaimer banner**: *"Opening Explorer requires a Lichess account. Sign in from the More tab."* No login step added to the onboarding flow itself — keep it standalone. |
| 3 | **Re-run onboarding** | Add a **"Replay app tour"** button in Settings (More tab → Settings screen). Tapping it resets `OnboardingPrefs.hasCompleted = false`, which causes `_AppRouter` to re-show `OnboardingScreen` automatically. Add as task `OB-T12`. |
