import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exochess_mobile/src/model/game/over_the_board_game.dart';
import 'package:exochess_mobile/src/model/over_the_board/over_the_board_game_controller.dart';
import 'package:exochess_mobile/src/styles/styles.dart';
import 'package:exochess_mobile/src/utils/l10n_context.dart';
import 'package:exochess_mobile/src/view/over_the_board/over_the_board_screen.dart';
import 'package:exochess_mobile/src/widgets/cyberpunk/cyberpunk.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:dartchess/dartchess.dart';

class OtbHistoryScreen extends ConsumerWidget {
  const OtbHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer(
      builder: (context, ref, _) {
        final history = ref.watch(otbHistoryLocalProvider);

        return history.when(
          data: (games) {
            if (games.isEmpty) {
              return Center(
                child: Text(
                  'NO OTB HISTORY YET',
                  style: TextStyle(
                    fontFamily: 'SpaceMono',
                    color: isDark ? Colors.white24 : Colors.black26,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: games.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _OtbHistoryItem(game: games[index]);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator.adaptive()),
          error: (e, _) => Center(child: Text('ERROR: $e')),
        );
      },
    );
  }
}

class _OtbHistoryItem extends StatelessWidget {
  const _OtbHistoryItem({required this.game});

  final OverTheBoardGame game;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.primary;

    final resultColor = game.winner == Side.white
        ? Colors.green
        : game.winner == Side.black
            ? const Color(0xFFD71921)
            : Colors.grey;

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context, rootNavigator: true).push(
            OverTheBoardScreen.buildRoute(
              context,
              initialVariant: game.meta.variant,
              initialFen: game.initialFen,
            ),
          );
        },
        borderRadius: Styles.cardBorderRadius,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: resultColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${game.meta.variant.label.toUpperCase()} GAME',
                      style: const TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${game.steps.length} MOVES • ${game.status.name.toUpperCase()}',
                      style: TextStyle(
                        fontFamily: 'SpaceMono',
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: accentColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
