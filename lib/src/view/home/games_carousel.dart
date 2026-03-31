import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exochess_mobile/src/model/account/ongoing_game.dart';
import 'package:exochess_mobile/src/model/settings/board_preferences.dart';
import 'package:exochess_mobile/src/styles/styles.dart';
import 'package:exochess_mobile/src/tab_scaffold.dart';
import 'package:exochess_mobile/src/utils/l10n.dart';
import 'package:exochess_mobile/src/utils/l10n_context.dart';
import 'package:exochess_mobile/src/widgets/list.dart';
import 'package:exochess_mobile/src/widgets/user.dart';

const _kDefaultCardOpacity = 0.9;
const kGameCarouselFlexWeights = [6, 2];
const kGameCarouselPadding = EdgeInsets.symmetric(horizontal: 8.0);

/// A widget that displays a carousel of games.
class GamesCarousel<T> extends StatefulWidget {
  const GamesCarousel({
    required this.list,
    required this.builder,
    required this.onTap,
    required this.moreScreenRouteBuilder,
    required this.maxGamesToShow,
  });
  final IList<T> list;
  final Widget Function(T data) builder;
  final void Function(int index)? onTap;
  final Route<dynamic> Function(BuildContext) moreScreenRouteBuilder;
  final int maxGamesToShow;

  @override
  State<GamesCarousel<T>> createState() => _GamesCarouselState<T>();
}

class _GamesCarouselState<T> extends State<GamesCarousel<T>> {
  final _controller = CarouselController();

  @override
  void initState() {
    super.initState();
    homeTabInteraction.addListener(_onTabInteraction);
  }

  @override
  void dispose() {
    homeTabInteraction.removeListener(_onTabInteraction);
    super.dispose();
  }

  void _onTabInteraction() {
    if (_controller.hasClients) {
      _controller.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: Styles.verticalBodyPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: Styles.horizontalBodyPadding,
            child: ListSectionHeader(
              title: Text(
                context.l10n.nbGamesInPlay(widget.list.length).toUpperCase(),
                style: const TextStyle(fontFamily: 'NDot', fontSize: 18),
              ),
              onTap: widget.list.length > 2
                  ? () {
                      Navigator.of(context).push(widget.moreScreenRouteBuilder(context));
                    }
                  : null,
            ),
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: AspectRatio(
              aspectRatio: 1.15,
              child: CarouselView.weighted(
                controller: _controller,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  side: BorderSide(color: theme.colorScheme.outline),
                ),
                elevation: 0,
                flexWeights: kGameCarouselFlexWeights,
                itemSnapping: true,
                onTap: (index) {
                  widget.onTap?.call(index);
                },
                children: [for (final game in widget.list) widget.builder(game)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A widget that displays an ongoing game carousel item.
///
/// Typically used in a [GamesCarousel].
class OngoingGameCarouselItem extends StatelessWidget {
  const OngoingGameCarouselItem({required this.game});

  final OngoingGame game;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final timeLeft = game.secondsLeft != null
        ? relativeDate(context.l10n, DateTime.now().add(Duration(seconds: game.secondsLeft!)))
        : null;
    final timeTextStyle = TextStyle(
      color: theme.colorScheme.onSurface,
      fontSize: 12,
      fontFamily: 'SpaceMono',
      fontWeight: FontWeight.bold,
    );

    return _BoardCarouselItem(
      isRealTimeGame: game.isRealTime,
      fen: game.fen,
      orientation: game.orientation,
      lastMove: game.lastMove,
      description: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (game.isMyTurn) ...[
                    Icon(Icons.timer, size: 14.0, color: theme.colorScheme.primary),
                    const SizedBox(width: 6.0),
                    if (timeLeft != null) Text(timeLeft.toUpperCase(), style: timeTextStyle),
                  ] else
                    Text(context.l10n.waitingForOpponent.toUpperCase(), style: timeTextStyle.copyWith(color: isDark ? Colors.white38 : Colors.black38)),
                ],
              ),
              const SizedBox(height: 4.0),
              UserFullNameWidget.player(
                user: game.opponent,
                rating: game.opponentRating,
                aiLevel: game.opponentAiLevel,
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoardCarouselItem extends ConsumerWidget {
  const _BoardCarouselItem({
    required this.orientation,
    required this.fen,
    required this.description,
    this.lastMove,
    this.isRealTimeGame = false,
  });

  /// Side by which the board is oriented.
  final Side orientation;

  /// FEN string describing the position of the board.
  final String fen;

  /// Last move played, used to highlight corresponding squares.
  final Move? lastMove;

  final Widget description;

  /// Whether the game is a real-time game, so it will be highlighted differently.
  final bool isRealTimeGame;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardPrefs = ref.watch(boardPreferencesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final totalFlex = kGameCarouselFlexWeights.reduce((a, b) => a + b);
    final double width = screenWidth - 16.0;
    final boardSize =
        width * kGameCarouselFlexWeights[0] / totalFlex - kGameCarouselPadding.horizontal;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.02),
      ),
      child: Stack(
        children: [
          SizedBox(
            height: boardSize,
            child: StaticChessboard(
              hue: boardPrefs.hue,
              brightness: boardPrefs.brightness,
              size: boardSize,
              fen: fen,
              orientation: orientation,
              lastMove: lastMove,
              enableCoordinates: false,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              pieceAssets: boardPrefs.pieceSet.assets,
              colorScheme: isRealTimeGame
                  ? realTimeColors(context)
                  : boardPrefs.boardTheme.colors,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: description,
          ),
        ],
      ),
    );
  }

  ChessboardColorScheme realTimeColors(BuildContext context) {
    final brag = context.exochessColors.brag;
    final lightSquare = lighten(brag, 0.55);
    final darkSquare = brag;
    return ChessboardColorScheme(
      lightSquare: lightSquare,
      darkSquare: darkSquare,
      background: SolidColorChessboardBackground(lightSquare: lightSquare, darkSquare: darkSquare),
      whiteCoordBackground: SolidColorChessboardBackground(
        lightSquare: lightSquare,
        darkSquare: darkSquare,
        coordinates: true,
      ),
      blackCoordBackground: SolidColorChessboardBackground(
        lightSquare: lightSquare,
        darkSquare: darkSquare,
        coordinates: true,
        orientation: Side.black,
      ),
      lastMove: const HighlightDetails(solidColor: Color(0x809cc700)),
      selected: const HighlightDetails(solidColor: Color(0x6014551e)),
      validMoves: const Color(0x4014551e),
      validPremoves: const Color(0x40203085),
    );
  }
}
