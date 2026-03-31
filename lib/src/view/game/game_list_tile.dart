import 'package:dartchess/dartchess.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:exochess_mobile/src/model/analysis/analysis_controller.dart';
import 'package:exochess_mobile/src/model/auth/auth_controller.dart';
import 'package:exochess_mobile/src/model/game/exported_game.dart';
import 'package:exochess_mobile/src/model/game/game_share_service.dart';
import 'package:exochess_mobile/src/model/game/game_status.dart';
import 'package:exochess_mobile/src/model/game/gif_export.dart';
import 'package:exochess_mobile/src/network/http.dart';
import 'package:exochess_mobile/src/styles/exochess_colors.dart';
import 'package:exochess_mobile/src/styles/styles.dart';
import 'package:exochess_mobile/src/utils/l10n.dart';
import 'package:exochess_mobile/src/utils/l10n_context.dart';
import 'package:exochess_mobile/src/utils/screen.dart';
import 'package:exochess_mobile/src/utils/share.dart';
import 'package:exochess_mobile/src/view/analysis/analysis_screen.dart';
import 'package:exochess_mobile/src/view/game/game_common_widgets.dart';
import 'package:exochess_mobile/src/view/game/gif_export_dialog.dart';
import 'package:exochess_mobile/src/view/game/status_l10n.dart';
import 'package:exochess_mobile/src/widgets/adaptive_bottom_sheet.dart';
import 'package:exochess_mobile/src/widgets/board_thumbnail.dart';
import 'package:exochess_mobile/src/widgets/feedback.dart';
import 'package:exochess_mobile/src/widgets/list.dart';
import 'package:exochess_mobile/src/widgets/user.dart';
import 'package:exochess_mobile/src/widgets/cyberpunk/glass_card.dart';
import 'package:share_plus/share_plus.dart';

final _dateFormatter = DateFormat.yMMMd().add_Hm();

/// A list tile for a game in a game list.
class GameListTile extends StatelessWidget {
  const GameListTile({required this.item, this.padding, this.onPressedBookmark});

  final LightExportedGameWithPov item;
  final EdgeInsetsGeometry? padding;
  final Future<void> Function(BuildContext context)? onPressedBookmark;

  @override
  Widget build(BuildContext context) {
    final (game: game, pov: youAre) = item;
    final me = youAre == Side.white ? game.white : game.black;
    final opponent = youAre == Side.white ? game.black : game.white;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget getResultIndicator(LightExportedGame game, Side mySide) {
      final Color resultColor;
      if (game.status == GameStatus.aborted || game.status == GameStatus.noStart) {
        resultColor = Colors.grey;
      } else {
        resultColor = game.winner == null
            ? Colors.grey
            : game.winner == mySide
            ? Colors.green
            : const Color(0xFFD71921);
      }

      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: resultColor,
          shape: BoxShape.circle,
        ),
      );
    }

    return ListTile(
      onTap: () => openGameScreen(
        context,
        game: item.game,
        orientation: item.pov,
        loadingFen: game.lastFen,
        loadingLastMove: game.lastMove,
        lastMoveAt: game.lastMoveAt,
      ),
      onLongPress: () {
        showModalBottomSheet<void>(
          context: context,
          useRootNavigator: true,
          isDismissible: true,
          isScrollControlled: true,
          builder: (context) => GameContextMenu(
            game: game,
            mySide: youAre,
            opponentTitle: UserFullNameWidget.player(
              user: opponent.user,
              aiLevel: opponent.aiLevel,
              rating: opponent.rating,
            ),
            onPressedBookmark: onPressedBookmark,
          ),
        );
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Icon(game.perf.icon, size: 20, color: theme.colorScheme.onSurface),
      ),
      title: UserFullNameWidget.player(
        user: opponent.user,
        aiLevel: opponent.aiLevel,
        rating: opponent.rating,
        style: const TextStyle(
          fontFamily: 'SpaceMono',
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        '${game.clockDisplay(context.l10n)} • ${relativeDate(context.l10n, game.lastMoveAt)}'.toUpperCase(),
        style: TextStyle(
          fontFamily: 'SpaceMono',
          fontSize: 11,
          color: isDark ? Colors.white38 : Colors.black38,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (me.analysis != null) ...[
            Icon(Icons.analytics_outlined, size: 16, color: isDark ? Colors.white24 : Colors.black26),
            const SizedBox(width: 12),
          ],
          getResultIndicator(game, youAre),
        ],
      ),
    );
  }
}

class GameContextMenu extends ConsumerWidget {
  const GameContextMenu({
    required this.game,
    required this.mySide,
    required this.opponentTitle,
    required this.onPressedBookmark,
  });

  final LightExportedGame game;
  final Side mySide;
  final Widget opponentTitle;
  final Future<void> Function(BuildContext context)? onPressedBookmark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orientation = mySide;

    final isLoggedIn = ref.watch(isLoggedInProvider);

    return BottomSheetScrollableContainer(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ).add(const EdgeInsets.only(bottom: 12.0)),
          child: Text(
            context.l10n.resVsX(
              game.white.fullName(context.l10n),
              game.black.fullName(context.l10n),
            ).toUpperCase(),
            style: const TextStyle(
              fontFamily: 'NDot',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final theme = Theme.of(context);
              final isDark = theme.brightness == Brightness.dark;
              
              return IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (game.lastFen != null)
                      BoardThumbnail(
                        size: constraints.maxWidth - (constraints.maxWidth / 1.618),
                        fen: game.lastFen!,
                        orientation: mySide,
                        lastMove: game.lastMove,
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${game.clockDisplay(context.l10n)} • ${game.rated ? context.l10n.rated : context.l10n.casual}'.toUpperCase(),
                                  style: const TextStyle(
                                    fontFamily: 'SpaceMono',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _dateFormatter.format(game.lastMoveAt).toUpperCase(),
                                  style: TextStyle(
                                    color: isDark ? Colors.white38 : Colors.black38,
                                    fontFamily: 'SpaceMono',
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            if (game.lastFen != null)
                              Text(
                                gameStatusL10n(
                                  context,
                                  variant: game.variant,
                                  status: game.status,
                                  lastPosition: Position.setupPosition(
                                    game.variant.rule,
                                    Setup.parseFen(game.lastFen!),
                                  ),
                                  winner: game.winner,
                                ).toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'SpaceMono',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: game.winner == null
                                      ? Colors.grey
                                      : game.winner == mySide
                                      ? Colors.green
                                      : const Color(0xFFD71921),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        ListSection(
          children: [
            BottomSheetContextMenuAction(
              icon: Icons.biotech,
              onPressed: game.variant.isReadSupported
                  ? () {
                      Navigator.of(context).push(
                        AnalysisScreen.buildRoute(
                          context,
                          AnalysisOptions.archivedGame(orientation: orientation, gameId: game.id),
                        ),
                      );
                    }
                  : () {
                      showSnackBar(
                        context,
                        'This variant is not supported yet.',
                        type: SnackBarType.info,
                      );
                    },
              child: Text(context.l10n.analysis),
            ),
            if (isLoggedIn && onPressedBookmark != null)
              BottomSheetContextMenuAction(
                onPressed: () => onPressedBookmark?.call(context),
                icon: game.isBookmarked
                    ? Icons.bookmark_remove_outlined
                    : Icons.bookmark_add_outlined,
                closeOnPressed: true,
                child: Text(
                  game.isBookmarked
                      ? context.l10n.mobileRemoveBookmark
                      : context.l10n.bookmarkThisGame,
                ),
              ),
            if (!isTabletOrLarger(context)) ...[
              BottomSheetContextMenuAction(
                onPressed: () {
                  launchShareDialog(
                    context,
                    ShareParams(uri: exochessUri('/${game.id}/${orientation.name}')),
                  );
                },
                icon: Theme.of(context).platform == TargetPlatform.iOS
                    ? Icons.ios_share
                    : Icons.share,
                child: Text(context.l10n.mobileShareGameURL),
              ),
              BottomSheetContextMenuAction(
                icon: Icons.gif,
                child: Text(context.l10n.gameAsGIF),
                onPressed: () {
                  showModalBottomSheet<GifExportOptions>(
                    context: context,
                    builder: (_) => GifExport(gameId: game.id, orientation: orientation),
                  );
                },
              ),
              BottomSheetContextMenuAction(
                icon: Icons.text_snippet,
                child: Text('PGN: ${context.l10n.downloadAnnotated}'),
                onPressed: () async {
                  try {
                    final pgn = await ref.read(gameShareServiceProvider).annotatedPgn(game.id);
                    if (context.mounted) {
                      launchShareDialog(context, ShareParams(text: pgn));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      showSnackBar(context, 'Failed to get PGN', type: SnackBarType.error);
                    }
                  }
                },
              ),
              BottomSheetContextMenuAction(
                icon: Icons.text_snippet,
                // TODO improve translation
                child: Text('PGN: ${context.l10n.downloadRaw}'),
                onPressed: () async {
                  try {
                    final pgn = await ref.read(gameShareServiceProvider).rawPgn(game.id);
                    if (context.mounted) {
                      launchShareDialog(context, ShareParams(text: pgn));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      showSnackBar(context, 'Failed to get PGN', type: SnackBarType.error);
                    }
                  }
                },
              ),
            ],
          ],
        ),
      ],
    );
  }
}
