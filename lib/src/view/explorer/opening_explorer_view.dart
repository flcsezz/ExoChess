import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chessigma_mobile/src/model/auth/auth_controller.dart';
import 'package:chessigma_mobile/src/model/common/chess.dart';
import 'package:chessigma_mobile/src/model/explorer/opening_explorer.dart';
import 'package:chessigma_mobile/src/model/explorer/opening_explorer_preferences.dart';
import 'package:chessigma_mobile/src/model/explorer/opening_explorer_repository.dart';
import 'package:chessigma_mobile/src/network/connectivity.dart';
import 'package:chessigma_mobile/src/theme.dart';
import 'package:chessigma_mobile/src/utils/l10n_context.dart';
import 'package:chessigma_mobile/src/view/explorer/opening_explorer_widgets.dart';
import 'package:chessigma_mobile/src/widgets/shimmer.dart';

/// Displays an opening explorer for the given position.
///
/// It shows the top moves, games, and recent games for the given position in a list view.
/// By default, the view is scrollable, but it can be disabled by setting [scrollable] to false.
///
/// This widget is meant to be embedded in the analysis, broadcast, and study screens.
///
/// Network requests are debounced and cached to avoid unnecessary requests.
class OpeningExplorerView extends ConsumerStatefulWidget {
  const OpeningExplorerView({
    required this.pov,
    required this.position,
    required this.onMoveSelected,
    this.opening,
    this.scrollable = true,
    this.shouldDisplayGames = true,
  });

  final Side pov;
  final Position position;
  final Opening? opening;
  final void Function(Move) onMoveSelected;
  final bool scrollable;

  /// Whether to display recent and top games in the explorer.
  final bool shouldDisplayGames;

  @override
  ConsumerState<OpeningExplorerView> createState() => _OpeningExplorerState();
}

class _OpeningExplorerState extends ConsumerState<OpeningExplorerView> {
  final Map<OpeningExplorerCacheKey, OpeningExplorerEntry> cache = {};

  /// Last explorer content that was successfully loaded. This is used to
  /// display a loading indicator while the new content is being fetched.
  List<Widget>? lastExplorerWidgets;

  @override
  Widget build(BuildContext context) {
    if (widget.position.ply >= 50) {
      return Center(child: Text(context.l10n.maxDepthReached));
    }

    final prefs = ref.watch(openingExplorerPreferencesProvider);

    // The Lichess Opening Explorer now requires authentication (anti-DDoS).
    // Show a friendly prompt instead of a cryptic network error.
    // NOTE: ChessDB (openingdatabase.chessdb) does NOT require login.
    final isLoggedIn = ref.watch(isLoggedInProvider);
    if (!isLoggedIn && prefs.db != OpeningDatabase.chessdb) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 40),
              const SizedBox(height: 12),
              Text(
                'Sign in to use the Opening Explorer',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Lichess requires a free account to access the opening database.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    // final prefs = ref.watch(openingExplorerPreferencesProvider); // Already watched above

    if (prefs.db == OpeningDatabase.player && prefs.playerDb.username == null) {
      return const Center(
        // TODO: l10n
        child: Text('Select a Chessigma player in the settings.'),
      );
    }

    final cacheKey = OpeningExplorerCacheKey(fen: widget.position.fen, prefs: prefs);
    final cacheOpeningExplorer = cache[cacheKey];
    final openingExplorerAsync = cacheOpeningExplorer != null
        ? AsyncValue.data((entry: cacheOpeningExplorer, isIndexing: false))
        : ref.watch(openingExplorerProvider(widget.position.fen));

    if (cacheOpeningExplorer == null) {
      ref.listen(openingExplorerProvider(widget.position.fen), (_, curAsync) {
        curAsync.whenData((cur) {
          if (cur != null && !cur.isIndexing) {
            cache[cacheKey] = cur.entry;
          }
        });
      });
    }

    switch (openingExplorerAsync) {
      case AsyncData(:final value):
        if (value == null) {
          return _ExplorerListView(
            scrollable: widget.scrollable,
            isLoading: true,
            children:
                lastExplorerWidgets ??
                [
                  const Shimmer(
                    child: ShimmerLoading(
                      isLoading: true,
                      child: OpeningExplorerMoveTable.loading(),
                    ),
                  ),
                ],
          );
        }

        final topGames = value.entry.topGames;
        final recentGames = value.entry.recentGames;

        final ply = widget.position.ply;

        final children = [
          if (widget.opening != null) OpeningNameHeader(opening: widget.opening!),
          OpeningExplorerMoveTable(
            moves: value.entry.moves,
            whiteWins: value.entry.white,
            draws: value.entry.draws,
            blackWins: value.entry.black,
            onMoveSelected: widget.onMoveSelected,
            isIndexing: value.isIndexing,
            database: prefs.db,
          ),
          if (widget.shouldDisplayGames && topGames != null && topGames.isNotEmpty) ...[
            OpeningExplorerHeaderTile(
              key: const Key('topGamesHeader'),
              child: Text(context.l10n.topGames),
            ),
            ...List.generate(topGames.length, (int index) {
              return OpeningExplorerGameTile(
                pov: widget.pov,
                key: Key('top-game-${topGames.get(index).id}'),
                game: topGames.get(index),
                color: index.isEven ? context.lichessTheme.rowEven : context.lichessTheme.rowOdd,
                ply: ply,
              );
            }, growable: false),
          ],
          if (widget.shouldDisplayGames && recentGames != null && recentGames.isNotEmpty) ...[
            OpeningExplorerHeaderTile(
              key: const Key('recentGamesHeader'),
              child: Text(context.l10n.recentGames),
            ),
            ...List.generate(recentGames.length, (int index) {
              return OpeningExplorerGameTile(
                pov: widget.pov,
                key: Key('recent-game-${recentGames.get(index).id}'),
                game: recentGames.get(index),
                color: index.isEven ? context.lichessTheme.rowEven : context.lichessTheme.rowOdd,
                ply: ply,
              );
            }, growable: false),
          ],
        ];

        lastExplorerWidgets = children;

        return _ExplorerListView(
          scrollable: widget.scrollable,
          isLoading: false,
          children: children,
        );
      case AsyncError(:final error):
        debugPrint('SEVERE: [OpeningExplorerView] could not load opening explorer data; $error');
        final connectivity = ref.watch(connectivityChangesProvider);
        final message = connectivity.whenIs(
          online: () => 'Could not reach the opening explorer. Please try again.',
          offline: () => context.l10n.mobileOpeningExplorerNotAvailableOffline,
        );
        return Center(
          child: Padding(padding: const EdgeInsets.all(16.0), child: Text(message)),
        );
      case _:
        return _ExplorerListView(
          scrollable: widget.scrollable,
          isLoading: true,
          children:
              lastExplorerWidgets ??
              [
                const Shimmer(
                  child: ShimmerLoading(isLoading: true, child: OpeningExplorerMoveTable.loading()),
                ),
              ],
        );
    }
  }
}

class _ExplorerListView extends StatelessWidget {
  const _ExplorerListView({
    required this.children,
    required this.isLoading,
    required this.scrollable,
  });

  final List<Widget> children;
  final bool isLoading;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final loadingOverlay = Positioned.fill(
      child: IgnorePointer(
        ignoring: !isLoading,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 400),
          curve: Curves.fastOutSlowIn,
          opacity: isLoading ? 0.20 : 0.0,
          child: ColoredBox(color: brightness == Brightness.dark ? Colors.black : Colors.white),
        ),
      ),
    );

    return Stack(
      children: [
        if (scrollable)
          ListView(padding: EdgeInsets.zero, children: children)
        else
          ListBody(children: children),
        loadingOverlay,
      ],
    );
  }
}
