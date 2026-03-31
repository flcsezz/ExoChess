import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exochess_mobile/src/model/account/account_repository.dart';
import 'package:exochess_mobile/src/model/auth/auth_controller.dart';
import 'package:exochess_mobile/src/model/game/game_history.dart';
import 'package:exochess_mobile/src/model/external_history/external_history_provider.dart';
import 'package:exochess_mobile/src/model/user/user.dart';
import 'package:exochess_mobile/src/model/user/user_repository.dart';
import 'package:exochess_mobile/src/network/http.dart';
import 'package:exochess_mobile/src/styles/styles.dart';
import 'package:exochess_mobile/src/utils/l10n_context.dart';
import 'package:exochess_mobile/src/utils/navigation.dart';
import 'package:exochess_mobile/src/utils/share.dart';
import 'package:exochess_mobile/src/view/account/edit_profile_screen.dart';
import 'package:exochess_mobile/src/view/account/game_bookmarks_screen.dart';
import 'package:exochess_mobile/src/view/user/perf_cards.dart';
import 'package:exochess_mobile/src/view/user/recent_games.dart';
import 'package:exochess_mobile/src/view/user/user_activity.dart';
import 'package:exochess_mobile/src/view/user/user_profile.dart';
import 'package:exochess_mobile/src/widgets/buttons.dart';
import 'package:exochess_mobile/src/widgets/feedback.dart';
import 'package:exochess_mobile/src/widgets/haptic_refresh_indicator.dart';
import 'package:exochess_mobile/src/widgets/list.dart';
import 'package:exochess_mobile/src/widgets/platform.dart';
import 'package:exochess_mobile/src/widgets/shimmer.dart';
import 'package:exochess_mobile/src/widgets/user.dart';
import 'package:share_plus/share_plus.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  static Route<dynamic> buildRoute(BuildContext context) {
    return buildScreenRoute(context, screen: const ProfileScreen());
  }

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

final _accountActivityProvider = FutureProvider.autoDispose<IList<UserActivity>>((ref) {
  final authUser = ref.watch(authControllerProvider);
  if (authUser == null) return IList();
  return ref.read(userRepositoryProvider).getActivity(authUser.user.id);
}, name: 'userActivityProvider');

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(accountProvider);
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: account.when(
          data: (user) => user == null
              ? const SizedBox.shrink()
              : Text(
                  user.username.toUpperCase(),
                  style: const TextStyle(fontFamily: 'NDot', fontSize: 20),
                ),
          loading: () => const SizedBox.shrink(),
          error: (error, _) => const SizedBox.shrink(),
        ),
        centerTitle: true,
        actions: [
          SemanticIconButton(
            icon: const Icon(Icons.edit_outlined),
            semanticsLabel: context.l10n.editProfile,
            onPressed: () => Navigator.of(context).push(EditProfileScreen.buildRoute(context)),
          ),
          account.when(
            data: (user) => user == null
                ? const SizedBox.shrink()
                : SemanticIconButton(
                    icon: const PlatformShareIcon(),
                    semanticsLabel: 'Share profile',
                    onPressed: () => launchShareDialog(
                      context,
                      ShareParams(uri: exochessUri('/@/${user.username}')),
                    ),
                  ),
            loading: () => const SizedBox.shrink(),
            error: (error, _) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: account.when(
        data: (user) {
          if (user == null) {
            return Center(child: Text(context.l10n.mobileMustBeLoggedIn));
          }
          final activity = ref.watch(_accountActivityProvider);
          final recentGames = ref.watch(myRecentGamesProvider);
          final nbOfGames = ref.watch(userNumberOfGamesProvider(null)).value ?? 0;
          final theme = Theme.of(context);

          return DefaultTabController(
            length: 3,
            child: HapticRefreshIndicator(
              edgeOffset: Theme.of(context).platform == TargetPlatform.iOS
                  ? MediaQuery.paddingOf(context).top + kToolbarHeight
                  : 0.0,
              key: _refreshIndicatorKey,
              onRefresh: () => Future.wait([
                ref.refresh(accountProvider.future),
                ref.refresh(_accountActivityProvider.future),
                ref.refresh(myRecentGamesProvider.future),
                ref.refresh(lichessRecentConvertedProvider.future),
                ref.refresh(chesscomRecentConvertedProvider.future),
              ]),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: UserProfileWidget(user: user)),
                  const SliverToBoxAdapter(child: AccountPerfCards()),
                  if (user.count != null && user.count!.bookmark > 0)
                    SliverToBoxAdapter(
                      child: ListSection(
                        hasLeading: true,
                        children: [
                          ListTile(
                            title: Text(context.l10n.nbBookmarks(user.count!.bookmark).toUpperCase(), style: const TextStyle(fontFamily: 'SpaceMono', fontWeight: FontWeight.bold)),
                            leading: const Icon(Icons.bookmarks_outlined),
                            onTap: () {
                              Navigator.of(context).push(
                                GameBookmarksScreen.buildRoute(
                                  context,
                                  nbBookmarks: user.count!.bookmark,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  SliverToBoxAdapter(child: UserActivityWidget(activity: activity, user: user.lightUser)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: Styles.horizontalBodyPadding,
                      child: TabBar(
                        dividerColor: Colors.transparent,
                        indicatorColor: theme.colorScheme.primary,
                        labelColor: theme.colorScheme.primary,
                        unselectedLabelColor: Colors.grey,
                        labelStyle: const TextStyle(fontFamily: 'SpaceMono', fontWeight: FontWeight.bold, fontSize: 12),
                        tabs: [
                          Tab(text: 'LOCAL'.toUpperCase()),
                          Tab(text: 'LICHESS'.toUpperCase()),
                          Tab(text: 'CHESS.COM'.toUpperCase()),
                        ],
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    child: TabBarView(
                      children: [
                        RecentGamesWidget(
                          recentGames: recentGames,
                          nbOfGames: nbOfGames,
                          user: null,
                          title: 'Local History',
                        ),
                        RecentGamesWidget(
                          recentGames: ref.watch(lichessRecentConvertedProvider),
                          nbOfGames: 0,
                          user: null,
                          title: 'Lichess History',
                        ),
                        RecentGamesWidget(
                          recentGames: ref.watch(chesscomRecentConvertedProvider),
                          nbOfGames: 0,
                          user: null,
                          title: 'Chess.com History',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (error, _) {
          return FullScreenRetryRequest(onRetry: () => ref.invalidate(accountProvider));
        },
      ),
    );
  }
}

class AccountPerfCards extends ConsumerWidget {
  const AccountPerfCards({this.padding});

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return account.when(
      data: (user) {
        if (user != null) {
          return PerfCards(user: user, isMe: true, padding: padding);
        } else {
          return const SizedBox.shrink();
        }
      },
      loading: () => Shimmer(
        child: Padding(
          padding: padding ?? Styles.bodySectionPadding,
          child: SizedBox(
            height: 120,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) => ShimmerLoading(
                isLoading: true,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.black12,
                    borderRadius: Styles.cardBorderRadius,
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}
