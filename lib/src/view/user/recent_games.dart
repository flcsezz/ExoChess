import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exochess_mobile/src/model/game/exported_game.dart';
import 'package:exochess_mobile/src/model/game/game_history.dart';
import 'package:exochess_mobile/src/model/user/user.dart';
import 'package:exochess_mobile/src/network/connectivity.dart';
import 'package:exochess_mobile/src/styles/styles.dart';
import 'package:exochess_mobile/src/utils/l10n_context.dart';
import 'package:exochess_mobile/src/view/game/game_list_tile.dart';
import 'package:exochess_mobile/src/view/user/game_history_screen.dart';
import 'package:exochess_mobile/src/widgets/list.dart';
import 'package:exochess_mobile/src/widgets/shimmer.dart';

/// A widget that show a list of recent games.
///
/// The [user] should be provided only if the games are for a specific user. If the
/// games are for the current logged in user, the [user] should be null.
class RecentGamesWidget extends ConsumerStatefulWidget {
  const RecentGamesWidget({
    required this.recentGames,
    required this.user,
    required this.nbOfGames,
    this.title,
    this.maxGamesToShow = kNumberOfRecentGames,
    this.showError = true,
    super.key,
  });

  final LightUser? user;
  final AsyncValue<IList<LightExportedGameWithPov>> recentGames;
  final int nbOfGames;
  final int maxGamesToShow;
  final String? title;
  final bool showError;

  @override
  ConsumerState<RecentGamesWidget> createState() => _RecentGamesWidgetState();
}

class _RecentGamesWidgetState extends ConsumerState<RecentGamesWidget> {
  bool _isExpanded = false;
  static const int _initialCount = 3;

  @override
  Widget build(BuildContext context) {
    final connectivity = ref.watch(connectivityChangesProvider);

    return widget.recentGames.when(
      data: (data) {
        if (data.isEmpty) {
          return const SizedBox.shrink();
        }
        final totalList = data.take(widget.maxGamesToShow).toList();
        final displayList = _isExpanded ? totalList : totalList.take(_initialCount).toList();
        
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Padding(
          padding: Styles.horizontalBodyPadding.add(Styles.sectionBottomPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      (widget.title ?? context.l10n.recentGames).toUpperCase(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontFamily: 'NDot',
                        letterSpacing: 1.2,
                      ),
                    ),
                    if (widget.nbOfGames > totalList.length)
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            GameHistoryScreen.buildRoute(
                              context,
                              user: widget.user,
                              isOnline: connectivity.value?.isOnline == true,
                            ),
                          );
                        },
                        child: Text(
                          'VIEW ALL',
                          style: TextStyle(
                            fontFamily: 'SpaceMono',
                            fontSize: 12,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Card(
                child: Column(
                  children: [
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: RepaintBoundary(
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: displayList.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: theme.colorScheme.outline.withOpacity(0.5),
                          ),
                          itemBuilder: (context, index) {
                            return GameListTile(item: displayList[index]);
                          },
                        ),
                      ),
                    ),

                    if (totalList.length > _initialCount)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                (_isExpanded ? 'COLLAPSE' : 'SHOW MORE').toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'SpaceMono',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) {
        debugPrint('SEVERE: [RecentGames] could not recent games; $error\n$stackTrace');
        if (!widget.showError) {
          return const SizedBox.shrink();
        }
        return const Padding(
          padding: Styles.bodySectionPadding,
          child: Text('Could not load recent games.'),
        );
      },
      loading: () => Shimmer(
        child: ShimmerLoading(
          isLoading: true,
          child: ListSection.loading(itemsNumber: 10, header: true, hasLeading: true),
        ),
      ),
    );
  }
}
