import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chessigma_mobile/src/binding.dart';
import 'package:chessigma_mobile/src/model/account/account_repository.dart';
import 'package:chessigma_mobile/src/model/account/home_preferences.dart';
import 'package:chessigma_mobile/src/model/account/home_widgets.dart';
import 'package:chessigma_mobile/src/model/account/ongoing_game.dart';
import 'package:chessigma_mobile/src/model/auth/auth_controller.dart';
import 'package:chessigma_mobile/src/model/common/id.dart';
import 'package:chessigma_mobile/src/model/correspondence/correspondence_game_storage.dart';
import 'package:chessigma_mobile/src/model/correspondence/offline_correspondence_game.dart';
import 'package:chessigma_mobile/src/model/engine/evaluation_preferences.dart';
import 'package:chessigma_mobile/src/model/engine/nnue_service.dart';
import 'package:chessigma_mobile/src/model/game/game_history.dart';
import 'package:chessigma_mobile/src/model/message/message_repository.dart';
import 'package:chessigma_mobile/src/model/user/user.dart';
import 'package:chessigma_mobile/src/network/connectivity.dart';
import 'package:chessigma_mobile/src/styles/styles.dart';
import 'package:chessigma_mobile/src/tab_scaffold.dart';
import 'package:chessigma_mobile/src/utils/focus_detector.dart';
import 'package:chessigma_mobile/src/utils/l10n.dart';
import 'package:chessigma_mobile/src/utils/l10n_context.dart';
import 'package:chessigma_mobile/src/utils/navigation.dart';
import 'package:chessigma_mobile/src/utils/screen.dart';
import 'package:chessigma_mobile/src/view/account/account_drawer.dart';
import 'package:chessigma_mobile/src/view/account/profile_screen.dart';
import 'package:chessigma_mobile/src/view/correspondence/offline_correspondence_game_screen.dart';
import 'package:chessigma_mobile/src/view/game/offline_correspondence_games_screen.dart';
import 'package:chessigma_mobile/src/view/home/games_carousel.dart';
import 'package:chessigma_mobile/src/view/home/external_game_fetch_widget.dart';
import 'package:chessigma_mobile/src/view/message/conversation_screen.dart';
import 'package:chessigma_mobile/src/view/play/play_bottom_sheet.dart';
import 'package:chessigma_mobile/src/view/play/play_menu.dart';
import 'package:chessigma_mobile/src/view/settings/engine_settings_screen.dart';
import 'package:chessigma_mobile/src/view/user/recent_games.dart';
import 'package:chessigma_mobile/src/widgets/feedback.dart';
import 'package:chessigma_mobile/src/widgets/haptic_refresh_indicator.dart';
import 'package:chessigma_mobile/src/widgets/list.dart';
import 'package:chessigma_mobile/src/widgets/misc.dart';
import 'package:chessigma_mobile/src/widgets/platform.dart';
import 'package:url_launcher/url_launcher.dart';

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

    return connectivity.when(
      skipLoadingOnReload: true,
      data: (status) {
        final authUser = ref.watch(authControllerProvider);
        final unreadChessigmaMessage = ref.watch(unreadMessagesProvider).value?.lichess == true;
        final offlineCorresGames = ref.watch(offlineOngoingCorrespondenceGamesProvider);
        final recentGames = ref.watch(myRecentGamesProvider);
        final nbOfGames = ref.watch(userNumberOfGamesProvider(null)).value ?? 0;
        final isTablet = isTabletOrLarger(context);

        // Show the welcome screen if not logged in and there are no recent games and no stored games
        // (i.e. first installation, or the user has never played a game)
        final shouldShowWelcomeScreen =
            authUser == null &&
            recentGames.maybeWhen(data: (data) => data.isEmpty, orElse: () => false);

        List<Widget> widgets;

        if (shouldShowWelcomeScreen) {
          final welcomeWidgets = [
            const _EditableWidget(
              widget: HomeEditableWidget.hello,
              shouldShow: true,
              child: _GreetingWidget(),
            ),
            _EditableWidget(
              widget: HomeEditableWidget.externalFetch,
              shouldShow: true,
              child: const ExternalGameFetchWidget(),
            ),
            if (!widget.editModeEnabled) ...[
              Padding(
                padding: Styles.bodySectionPadding,
                child: ChessigmaMessage(style: TextTheme.of(context).bodyLarge),
              ),
              const SizedBox(height: 8.0),
              const _WelcomeMessageCard(),
              const _HomeCustomizationTip(),
            ],
          ];

          widgets = [
            if (isTablet)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...welcomeWidgets,
                        const SizedBox(height: 32.0),
                        const _TabletCreateAGameSection(),
                      ],
                    ),
                  ),
                ],
              )
            else ...[
              ...welcomeWidgets,
            ],
          ];
        } else if (isTablet) {
          widgets = [
            const _EditableWidget(
              widget: HomeEditableWidget.hello,
              shouldShow: true,
              child: _GreetingWidget(),
            ),
            if (!widget.editModeEnabled) ...[
              const _HomeCustomizationTip(),
              const _NNUEFilesOutdatedTip(),
            ],
            if (status.isOnline)
              _EditableWidget(
                widget: HomeEditableWidget.perfCards,
                shouldShow: authUser != null,
                child: const AccountPerfCards(padding: Styles.bodySectionPadding),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Column(
                    children: [
                      const SizedBox(height: 8.0),
                      const _TabletCreateAGameSection(),
                      _EditableWidget(
                        widget: HomeEditableWidget.externalFetch,
                        shouldShow: true,
                        child: const ExternalGameFetchWidget(),
                        ),

                      _OfflineCorrespondencePreview(offlineCorresGames, maxGamesToShow: 5),
                    ],
                  ),
                ),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8.0),
                      RecentGamesWidget(recentGames: recentGames, nbOfGames: nbOfGames, user: null),
                    ],
                  ),
                ),
              ],
            ),
          ];
        } else {
          final hasOngoingGames = offlineCorresGames.maybeWhen(
            data: (data) => data.isNotEmpty,
            orElse: () => false,
          );
          widgets = [
            const _EditableWidget(
              widget: HomeEditableWidget.hello,
              shouldShow: true,
              child: _GreetingWidget(),
            ),
            if (!widget.editModeEnabled) ...[
              const _HomeCustomizationTip(),
              const _NNUEFilesOutdatedTip(),
            ],
            _EditableWidget(
              widget: HomeEditableWidget.perfCards,
              shouldShow: authUser != null && status.isOnline,
              child: AccountPerfCards(
                padding: Styles.horizontalBodyPadding.add(Styles.sectionBottomPadding),
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
              child: RecentGamesWidget(recentGames: recentGames, nbOfGames: nbOfGames, user: null),
            ),
          ];
        }

        final content = ListView(
          controller: homeScrollController,
          children: [if (unreadChessigmaMessage) const _ChessigmaMessageBanner(), ...widgets],
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
              _refreshData(isOnline: status.isOnline);
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
                      title: const AppBarChessigmaTitle(),
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
                      onRefresh: () => _refreshData(isOnline: status.isOnline),
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
      },
      error: (_, _) => const CenterLoadingIndicator(),
      loading: () => const CenterLoadingIndicator(),
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

class _ChessigmaMessageBanner extends ConsumerWidget {
  const _ChessigmaMessageBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return InkWell(
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
      child: ColoredBox(
        color: theme.colorScheme.tertiaryContainer,
        child: Padding(
          padding: Styles.bodyPadding,
          child: Column(
            children: [
              Text(
                context.l10n.showUnreadChessigmaMessage,
                style: TextStyle(
                  color: theme.colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                context.l10n.clickHereToReadIt,
                style: TextStyle(color: theme.colorScheme.onTertiaryContainer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignInWidget extends ConsumerWidget {
  const _SignInWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signInState = ref.watch(signInMutation);

    return FilledButton(
      onPressed: switch (signInState) {
        MutationPending() => null,
        _ => () {
          signInMutation.run(ref, (tsx) async {
            await tsx.get(authControllerProvider.notifier).signIn();
          });
        },
      },
      child: Text(context.l10n.signIn),
    );
  }
}

/// A widget that can be enabled or disabled by the user.
///
/// This widget is used to show or hide certain sections of the home screen.
///
/// The [homePreferencesProvider] provides a list of enabled widgets.
///
/// * The [widget] parameter is the widget that can be enabled or disabled.
///
/// * The [shouldShow] parameter is useful when the widget should be shown only
///   when certain conditions are met. For example, we only want to show the quick
///   pairing matrix when the user is online.
///   This parameter is only active when the user is not in edit mode, as we
///   always want to display the widget in edit mode.
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
    final isDayTime = ref.watch(_isDayTimeProvider);
    final style = TextTheme.of(context).bodyLarge;

    const iconSize = 24.0;

    final user = authUser?.user;

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: Padding(
        padding: Styles.bodyPadding,
        child: GestureDetector(
          onTap: () {
            ref.invalidate(accountProvider);
            Navigator.of(context).push(ProfileScreen.buildRoute(context));
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isDayTime ? '☀️' : '🌙',
                style: const TextStyle(fontSize: iconSize, height: 1.0),
              ),
              const SizedBox(width: 5.0),
              if (user != null)
                Flexible(
                  child: l10nWithWidget(
                    isDayTime ? context.l10n.mobileGoodDay : context.l10n.mobileGoodEvening,
                    Text(user.name, style: style),
                    textStyle: style,
                  ),
                )
              else
                Flexible(
                  child: Text(
                    isDayTime
                        ? context.l10n.mobileGoodDayWithoutName
                        : context.l10n.mobileGoodEveningWithoutName,
                    style: style,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabletCreateAGameSection extends StatelessWidget {
  const _TabletCreateAGameSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        PlayMenu(),
      ],
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

class _OfflineCorrespondencePreview extends ConsumerWidget {
  const _OfflineCorrespondencePreview(this.offlineCorresGames, {required this.maxGamesToShow});

  final int maxGamesToShow;

  final AsyncValue<IList<(DateTime, OfflineCorrespondenceGame)>> offlineCorresGames;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return offlineCorresGames.maybeWhen(
      data: (data) {
        return PreviewGameList(
          list: data,
          maxGamesToShow: maxGamesToShow,
          builder: (el) => OfflineCorrespondenceGamePreview(game: el.$2, lastModified: el.$1),
          moreScreenRouteBuilder: OfflineCorrespondenceGamesScreen.buildRoute,
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

    return Padding(
      padding: Styles.horizontalBodyPadding.add(Styles.sectionTopPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListSectionHeader(
            title: Text(context.l10n.nbGamesInPlay(list.length)),
            onTap: list.length > maxGamesToShow
                ? () {
                    Navigator.of(context).push(moreScreenRouteBuilder(context));
                  }
                : null,
          ),
          for (final data in list.take(maxGamesToShow)) builder(data),
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
    return ChessigmaBinding.instance.sharedPreferences.getBool(kWelcomeMessageShownKey) != true;
  }

  void _dismiss() {
    ChessigmaBinding.instance.sharedPreferences.setBool(kWelcomeMessageShownKey, true);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldDisplay()) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: Styles.bodyPadding,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${context.l10n.mobileWelcomeToChessigmaApp}\n\n',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      TextSpan(
                        text: context.l10n.mobileNotAllFeaturesAreAvailable,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [TextButton(onPressed: _dismiss, child: Text(context.l10n.ok))],
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
          final hasOutdatedNNUEFiles = snapshot.data ?? false;
          if (!hasOutdatedNNUEFiles) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: Styles.bodyPadding,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning,
                            size: 25.0,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8.0),
                          const Flexible(
                            child: Text(
                              // TODO l10n
                              'New Stockfish version available! Go to the settings to download the updated NNUE files.',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _openedSettings = true;
                            });
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).push(EngineSettingsScreen.buildRoute(context));
                          },
                          // TODO l10n
                          child: const Text('Open settings'),
                        ),
                      ],
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
    final prefs = ChessigmaBinding.instance.sharedPreferences;

    return prefs.getBool(kHideHomeWidgetCustomizationTip) != true &&
        ChessigmaBinding.instance.numAppStarts <= kColdAppStartsHideCustomizationTipThreshold;
  }

  void _setHideHomeWidgetCustomizationTip(BuildContext context) {
    ChessigmaBinding.instance.sharedPreferences.setBool(kHideHomeWidgetCustomizationTip, true);

    // trigger rebuild to hide the tip
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldDisplayHomeWidgetCustomizationTip()) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: Styles.bodyPadding,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_circle_outlined,
                      size: 25.0,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8.0),
                    Flexible(child: Text(context.l10n.mobileCustomizeHomeTip)),
                  ],
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).push(HomeTabScreen.buildRoute(context, editModeEnabled: true));

                      _setHideHomeWidgetCustomizationTip(context);
                    },
                    child: Text(context.l10n.mobileCustomizeButton),
                  ),
                  TextButton(
                    onPressed: () {
                      _setHideHomeWidgetCustomizationTip(context);
                    },
                    child: Text(context.l10n.mobileCustomizeHomeTipDismiss),
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
