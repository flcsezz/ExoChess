import 'dart:async';

import 'package:exochess_mobile/src/binding.dart';
import 'package:exochess_mobile/src/model/account/account_repository.dart';
import 'package:exochess_mobile/src/model/account/home_preferences.dart';
import 'package:exochess_mobile/src/model/account/home_widgets.dart';
import 'package:exochess_mobile/src/model/account/ongoing_game.dart';
import 'package:exochess_mobile/src/model/auth/auth_controller.dart';
import 'package:exochess_mobile/src/model/common/id.dart';
import 'package:exochess_mobile/src/model/correspondence/correspondence_game_storage.dart';
import 'package:exochess_mobile/src/model/correspondence/offline_correspondence_game.dart';
import 'package:exochess_mobile/src/model/engine/evaluation_preferences.dart';
import 'package:exochess_mobile/src/model/engine/nnue_service.dart';
import 'package:exochess_mobile/src/model/game/game_history.dart';
import 'package:exochess_mobile/src/model/message/message_repository.dart';
import 'package:exochess_mobile/src/model/onboarding/onboarding_preferences.dart';
import 'package:exochess_mobile/src/model/user/user.dart';
import 'package:exochess_mobile/src/network/connectivity.dart';
import 'package:exochess_mobile/src/styles/styles.dart';
import 'package:exochess_mobile/src/tab_scaffold.dart';
import 'package:exochess_mobile/src/utils/focus_detector.dart';
import 'package:exochess_mobile/src/utils/l10n_context.dart';
import 'package:exochess_mobile/src/utils/navigation.dart';
import 'package:exochess_mobile/src/utils/screen.dart';
import 'package:exochess_mobile/src/view/account/account_drawer.dart';
import 'package:exochess_mobile/src/view/account/profile_screen.dart';
import 'package:exochess_mobile/src/view/correspondence/offline_correspondence_game_screen.dart';
import 'package:exochess_mobile/src/view/game/offline_correspondence_games_screen.dart';
import 'package:exochess_mobile/src/view/home/external_game_fetch_widget.dart';
import 'package:exochess_mobile/src/view/home/games_carousel.dart';
import 'package:exochess_mobile/src/view/message/conversation_screen.dart';
import 'package:exochess_mobile/src/view/play/play_bottom_sheet.dart';
import 'package:exochess_mobile/src/view/settings/engine_settings_screen.dart';
import 'package:exochess_mobile/src/view/user/recent_games.dart';
import 'package:exochess_mobile/src/widgets/feedback.dart';
import 'package:exochess_mobile/src/widgets/haptic_refresh_indicator.dart';
import 'package:exochess_mobile/src/widgets/list.dart';
import 'package:exochess_mobile/src/widgets/misc.dart';
import 'package:exochess_mobile/src/widgets/platform.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Number of cold app starts before hiding the home customization tip.
const kColdAppStartsHideCustomizationTipThreshold = 5;

class HomeTabScreen extends ConsumerStatefulWidget {
  const HomeTabScreen({super.key, this.editModeEnabled = false});

  final bool editModeEnabled;

  static Route<dynamic> buildRoute(BuildContext context, {bool editModeEnabled = false}) {
    return buildScreenRoute(context, screen: HomeTabScreen(editModeEnabled: editModeEnabled));
  }

  @override
  ConsumerState<HomeTabScreen> createState() => _HomeScreenState();
}

class _IsEditingHome extends InheritedWidget {
  const _IsEditingHome({required super.child, required this.isEditingWidgets});

  final bool isEditingWidgets;

  @override
  bool updateShouldNotify(_IsEditingHome oldWidget) {
    return isEditingWidgets != oldWidget.isEditingWidgets;
  }

  static _IsEditingHome? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_IsEditingHome>();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('isEditingWidgets', isEditingWidgets));
  }
}

const String kWelcomeMessageShownKey = 'app_welcome_message_shown';
const String kHideHomeWidgetCustomizationTip = 'app_hide_home_widget_customization_tip';

class _HomeScreenState extends ConsumerState<HomeTabScreen> {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  DateTime? _focusLostAt;

  bool wasOnline = true;
  bool hasRefreshed = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(connectivityChangesProvider, (_, connectivity) {
      // Refresh the data only once if it was offline and is now online
      if (!connectivity.isRefreshing && connectivity.hasValue) {
        final isNowOnline = connectivity.value!.isOnline;

        if (!hasRefreshed && !wasOnline && isNowOnline) {
          hasRefreshed = true;
          _refreshData(isOnline: isNowOnline);
        }

        wasOnline = isNowOnline;
      }
    });

    final connectivity = ref.watch(connectivityChangesProvider);
    final authUser = ref.watch(authControllerProvider);
    final unreadExoChessMessage = ref.watch(unreadMessagesProvider).value?.lichess == true;
    final offlineCorresGames = ref.watch(offlineOngoingCorrespondenceGamesProvider);
    final recentGames = ref.watch(myRecentGamesProvider);
    final nbOfGames = ref.watch(userNumberOfGamesProvider(null)).value ?? 0;
    final isTablet = isTabletOrLarger(context);

    final status = connectivity.value;
    final isOnline = status?.isOnline ?? false;

    final hasOngoingGames = offlineCorresGames.maybeWhen(
      data: (data) => data.isNotEmpty,
      orElse: () => false,
    );

    final widgets = [
      if (!widget.editModeEnabled) ...[
        const _HomeCustomizationTip(),
        const _NNUEFilesOutdatedTip(),
      ],
      _EditableWidget(
        widget: HomeEditableWidget.perfCards,
        shouldShow: authUser != null && isOnline,
        child: AccountPerfCards(
          padding: Styles.horizontalBodyPadding.add(const EdgeInsets.only(bottom: 12.0)),
        ),
      ),
      _EditableWidget(
        widget: HomeEditableWidget.ongoingGames,
        shouldShow: hasOngoingGames,
        child: _OfflineCorrespondenceCarousel(offlineCorresGames, maxGamesToShow: 20),
      ),
      _EditableWidget(
        widget: HomeEditableWidget.externalFetch,
        shouldShow: true,
        child: const ExternalGameFetchWidget(),
      ),

      _EditableWidget(
        widget: HomeEditableWidget.recentGames,
        shouldShow: true,
        child: RecentGamesWidget(
          recentGames: recentGames,
          nbOfGames: nbOfGames,
          user: null,
          showError: false,
        ),
      ),
    ];

    debugPrint('DEBUG: HomeTabScreen build. isOnline: $isOnline, authUser: \${authUser?.user.id}, hasOngoingGames: $hasOngoingGames');
    debugPrint('DEBUG: Home widgets count: \${widgets.length}');

    final content = CustomScrollView(
      controller: homeScrollController,
      slivers: [
        if (unreadExoChessMessage)
          const SliverToBoxAdapter(child: _ExoChessMessageBanner()),
        const SliverToBoxAdapter(child: SizedBox(height: 4)),
        const SliverToBoxAdapter(
          child: _EditableWidget(
            widget: HomeEditableWidget.hello,
            shouldShow: true,
            child: _GreetingWidget(),
          ),
        ),
        if (!widget.editModeEnabled)
          const SliverToBoxAdapter(child: _WelcomeMessageCard()),
        for (final widget in widgets) SliverToBoxAdapter(child: widget),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 32.0),
            child: Center(
              child: Text(
                'ExoChess is a Free and Opensourced Hobby Project XD',
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)), // Space for FAB
      ],
    );

    return FocusDetector(
      onFocusLost: () {
        _focusLostAt = DateTime.now();
      },
      onFocusRegained: () {
        if (context.mounted && _focusLostAt != null) {
          final duration = DateTime.now().difference(_focusLostAt!);
          if (duration.inSeconds < 10) {
            return;
          }
          _refreshData(isOnline: isOnline);
        }
      },
      child: _IsEditingHome(
        isEditingWidgets: widget.editModeEnabled,
        child: PlatformScaffold(
          appBar: widget.editModeEnabled
              ? PlatformAppBar(
                  title: Text(context.l10n.mobileSettingsHomeWidgets),
                  leading: const BackButton(),
                  automaticallyImplyLeading: false,
                )
              : PlatformAppBar(
                  title: const AppBarExoChessTitle(),
                  centerTitle: true,
                  leading: const SettingsIconButton(),
                ),
          body: widget.editModeEnabled
              ? content
              : HapticRefreshIndicator(
                  edgeOffset: Theme.of(context).platform == TargetPlatform.iOS
                      ? MediaQuery.paddingOf(context).top + kToolbarHeight
                      : 0.0,
                  key: _refreshKey,
                  onRefresh: () => _refreshData(isOnline: isOnline),
                  child: content,
                ),
          bottomNavigationBar: widget.editModeEnabled
              ? BottomAppBar(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(context.l10n.ok),
                      ),
                    ],
                  ),
                )
              : null,
          floatingActionButton: widget.editModeEnabled || isTablet
              ? null
              : const FloatingPlayButton(),
          bottomSheet: widget.editModeEnabled ? null : const OfflineBanner(),
        ),
      ),
    );
  }

  Future<void> _refreshData({required bool isOnline}) {
    return Future.wait([
      ref.refresh(myRecentGamesProvider.future),
      if (isOnline) ref.refresh(unreadMessagesProvider.future),
      if (isOnline) ref.refresh(accountProvider.future),
    ]);
  }
}

class _ExoChessMessageBanner extends ConsumerWidget {
  const _ExoChessMessageBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: Styles.horizontalBodyPadding,
      child: Card(
        color: theme.colorScheme.primary,
        child: InkWell(
          onTap: () {
            Navigator.of(context)
                .push(
                  ConversationScreen.buildRoute(
                    context,
                    user: const LightUser(id: UserId('lichess'), name: 'lichess'),
                  ),
                )
                .then((_) => ref.invalidate(unreadMessagesProvider));
          },
          borderRadius: Styles.cardBorderRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
            child: Column(
              children: [
                Text(
                  context.l10n.showUnreadExoChessMessage.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'NDot',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  context.l10n.clickHereToReadIt.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'SpaceMono',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A widget that can be enabled or disabled by the user.
class _EditableWidget extends ConsumerWidget {
  const _EditableWidget({required this.child, required this.widget, required this.shouldShow});

  final Widget child;
  final HomeEditableWidget widget;
  final bool shouldShow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disabledWidgets = ref.watch(homePreferencesProvider).disabledWidgets;
    final isEditing = _IsEditingHome.maybeOf(context)?.isEditingWidgets ?? false;
    final isEnabled = !disabledWidgets.contains(widget);

    debugPrint('DEBUG: _EditableWidget(widget: \$widget, shouldShow: \$shouldShow, isEnabled: \$isEnabled)');

    if (!shouldShow) {
      return const SizedBox.shrink();
    }

    return isEditing
        ? Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox.adaptive(
                      value: isEnabled,
                      onChanged: widget.alwaysEnabled
                          ? null
                          : (_) {
                              ref.read(homePreferencesProvider.notifier).toggleWidget(widget);
                            },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: IgnorePointer(ignoring: isEditing, child: child),
              ),
            ],
          )
        : widget.alwaysEnabled || isEnabled
        ? child
        : const SizedBox.shrink();
  }
}

class _IsDayTimeNotifier extends Notifier<bool> {
  Timer? _timer;

  @override
  bool build() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      ref.invalidateSelf();
    });

    ref.onDispose(() {
      _timer?.cancel();
    });

    final hour = DateTime.now().hour;
    return hour >= 6 && hour < 18; // Daytime is between 6 AM and 6 PM
  }
}

final _isDayTimeProvider = NotifierProvider.autoDispose<_IsDayTimeNotifier, bool>(
  _IsDayTimeNotifier.new,
  name: '_isDayTimeProvider',
);

class _GreetingWidget extends ConsumerWidget {
  const _GreetingWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authControllerProvider);
    final onboardingPrefs = ref.watch(onboardingPreferencesProvider);
    final isDayTime = ref.watch(_isDayTimeProvider);
    final style = TextTheme.of(context).titleLarge?.copyWith(
      fontFamily: 'NDot',
      fontSize: 28,
      height: 1.2,
    );

    const iconSize = 32.0;

    final user = authUser?.user;
    // Priority: Lichess username → onboarding display name → 'USER'
    final userName = user?.name ?? onboardingPrefs.displayName ?? 'USER';

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: Padding(
        padding: Styles.horizontalBodyPadding.add(const EdgeInsets.symmetric(vertical: 8.0)),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            ref.invalidate(accountProvider);
            Navigator.of(context).push(ProfileScreen.buildRoute(context));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isDayTime ? '☀️' : '🌙',
                    style: const TextStyle(fontSize: iconSize, height: 1.0),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                '${(isDayTime ? context.l10n.mobileGoodDayWithoutName : context.l10n.mobileGoodEveningWithoutName).toUpperCase()},',
                style: style,
              ),
              Text(
                userName.toUpperCase(),
                style: style?.copyWith(
                  color: const Color(0xFFD71921), // brand red
                  fontSize: 25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfflineCorrespondenceCarousel extends ConsumerWidget {
  const _OfflineCorrespondenceCarousel(this.offlineCorresGames, {required this.maxGamesToShow});

  final int maxGamesToShow;

  final AsyncValue<IList<(DateTime, OfflineCorrespondenceGame)>> offlineCorresGames;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return offlineCorresGames.maybeWhen(
      data: (data) {
        if (data.isEmpty) {
          return const SizedBox.shrink();
        }
        return GamesCarousel(
          list: data,
          onTap: (index) {
            final el = data[index];
            Navigator.of(context, rootNavigator: true).push(
              OfflineCorrespondenceGameScreen.buildRoute(context, initialGame: (el.$1, el.$2)),
            );
          },
          builder: (el) => OngoingGameCarouselItem(
            game: OngoingGame(
              id: el.$2.id,
              fullId: el.$2.fullId,
              orientation: el.$2.orientation,
              fen: el.$2.lastPosition.fen,
              perf: el.$2.perf,
              speed: el.$2.speed,
              variant: el.$2.variant,
              opponent: el.$2.opponent!.user,
              isMyTurn: el.$2.isMyTurn,
              opponentRating: el.$2.opponent!.rating,
              opponentAiLevel: el.$2.opponent!.aiLevel,
              lastMove: el.$2.lastMove,
              secondsLeft: el.$2.myTimeLeft(el.$1)?.inSeconds,
            ),
          ),
          moreScreenRouteBuilder: OfflineCorrespondenceGamesScreen.buildRoute,
          maxGamesToShow: maxGamesToShow,
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class PreviewGameList<T> extends StatelessWidget {
  const PreviewGameList({
    required this.list,
    required this.builder,
    required this.moreScreenRouteBuilder,
    required this.maxGamesToShow,
  });
  final IList<T> list;
  final Widget Function(T data) builder;
  final Route<dynamic> Function(BuildContext) moreScreenRouteBuilder;
  final int maxGamesToShow;

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Padding(
      padding: Styles.horizontalBodyPadding.add(Styles.sectionTopPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
            child: ListSectionHeader(
              title: Text(
                context.l10n.nbGamesInPlay(list.length).toUpperCase(),
                style: const TextStyle(fontFamily: 'NDot', fontSize: 18),
              ),
              onTap: list.length > maxGamesToShow
                  ? () {
                      Navigator.of(context).push(moreScreenRouteBuilder(context));
                    }
                  : null,
            ),
          ),
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.take(maxGamesToShow).length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
              ),
              itemBuilder: (context, index) => builder(list[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeMessageCard extends StatefulWidget {
  const _WelcomeMessageCard();

  @override
  State<_WelcomeMessageCard> createState() => _WelcomeMessageCardState();
}

class _WelcomeMessageCardState extends State<_WelcomeMessageCard> {
  bool _shouldDisplay() {
    return ExoChessBinding.instance.sharedPreferences.getBool(kWelcomeMessageShownKey) != true;
  }

  void _dismiss() {
    ExoChessBinding.instance.sharedPreferences.setBool(kWelcomeMessageShownKey, true);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldDisplay()) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: Styles.bodyPadding,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.mobileWelcomeToExoChessApp.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'NDot',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                context.l10n.mobileNotAllFeaturesAreAvailable.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24.0),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: _dismiss,
                  child: Text(context.l10n.ok.toUpperCase()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NNUEFilesOutdatedTip extends ConsumerStatefulWidget {
  const _NNUEFilesOutdatedTip();

  @override
  ConsumerState<_NNUEFilesOutdatedTip> createState() => _NNUEFilesOutdatedTipState();
}

class _NNUEFilesOutdatedTipState extends ConsumerState<_NNUEFilesOutdatedTip> {
  bool _openedSettings = false;
  late Future<bool> _checkNNUEFilesFuture;

  @override
  void initState() {
    super.initState();
    _checkNNUEFilesFuture = ref.read(nnueServiceProvider).hasOutdatedNNUEFiles();
  }

  @override
  Widget build(BuildContext context) {
    final chessEnginePref = ref.watch(engineEvaluationPreferencesProvider).enginePref;
    if (chessEnginePref != ChessEnginePref.sfLatest) {
      return const SizedBox.shrink();
    }

    final nnueService = ref.watch(nnueServiceProvider);
    if (nnueService.isDownloadingNNUEFiles) {
      return const SizedBox.shrink();
    }

    return FocusDetector(
      // If we come back from the settings, trigger rebuild to hide the widget if the user has updated the NNUE files
      onFocusRegained: () {
        if (_openedSettings) {
          setState(() {
            _checkNNUEFilesFuture = nnueService.hasOutdatedNNUEFiles();
            _openedSettings = false;
          });
        }
      },
      child: FutureBuilder(
        future: _checkNNUEFilesFuture,
        builder: (context, snapshot) {
          final theme = Theme.of(context);
          final hasOutdatedNNUEFiles = snapshot.data ?? false;
          if (!hasOutdatedNNUEFiles) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: Styles.horizontalBodyPadding.add(const EdgeInsets.symmetric(vertical: 8.0)),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 24.0,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12.0),
                        const Text(
                          'ENGINE UPDATE',
                          style: TextStyle(
                            fontFamily: 'NDot',
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'NEW STOCKFISH VERSION AVAILABLE! UPDATE NNUE FILES IN SETTINGS FOR BEST PERFORMANCE.'
                          .toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 11,
                        color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: () {
                          setState(() {
                            _openedSettings = true;
                          });
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).push(EngineSettingsScreen.buildRoute(context));
                        },
                        child: const Text(
                          'OPEN SETTINGS',
                          style: TextStyle(fontFamily: 'SpaceMono', fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HomeCustomizationTip extends StatefulWidget {
  const _HomeCustomizationTip();

  @override
  State<_HomeCustomizationTip> createState() => _HomeCustomizationTipState();
}

class _HomeCustomizationTipState extends State<_HomeCustomizationTip> {
  bool _shouldDisplayHomeWidgetCustomizationTip() {
    final prefs = ExoChessBinding.instance.sharedPreferences;

    return prefs.getBool(kHideHomeWidgetCustomizationTip) != true &&
        ExoChessBinding.instance.numAppStarts <= kColdAppStartsHideCustomizationTipThreshold;
  }

  void _setHideHomeWidgetCustomizationTip(BuildContext context) {
    ExoChessBinding.instance.sharedPreferences.setBool(kHideHomeWidgetCustomizationTip, true);

    // trigger rebuild to hide the tip
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldDisplayHomeWidgetCustomizationTip()) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: Styles.horizontalBodyPadding.add(const EdgeInsets.symmetric(vertical: 8.0)),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_outlined,
                    size: 24.0,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12.0),
                  Text(
                    'CUSTOMIZE HOME',
                    style: TextStyle(
                      fontFamily: 'NDot',
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Text(
                context.l10n.mobileCustomizeHomeTip.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 11,
                  color: isDark ? Colors.white70 : Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _setHideHomeWidgetCustomizationTip(context);
                    },
                    child: Text(
                      context.l10n.mobileCustomizeHomeTipDismiss.toUpperCase(),
                      style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).push(HomeTabScreen.buildRoute(context, editModeEnabled: true));

                      _setHideHomeWidgetCustomizationTip(context);
                    },
                    child: Text(
                      context.l10n.mobileCustomizeButton.toUpperCase(),
                      style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
