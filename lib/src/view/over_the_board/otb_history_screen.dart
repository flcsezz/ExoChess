import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chessigma_mobile/src/model/game/over_the_board_game.dart';
import 'package:chessigma_mobile/src/model/over_the_board/over_the_board_game_controller.dart';
import 'package:chessigma_mobile/src/utils/l10n_context.dart';
import 'package:chessigma_mobile/src/view/over_the_board/over_the_board_screen.dart';
import 'package:chessigma_mobile/src/widgets/cyberpunk/cyberpunk.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:dartchess/dartchess.dart';

class OtbHistoryScreen extends ConsumerWidget {
  const OtbHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(otbHistoryLocalProvider);

    return history.when(
      data: (games) {
        if (games.isEmpty) {
          return const Center(
            child: Text(
              'No OTB history yet',
              style: TextStyle(color: Colors.white24),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: games.length,
          itemBuilder: (context, index) {
            return _OtbHistoryItem(game: games[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _OtbHistoryItem extends StatelessWidget {
  const _OtbHistoryItem({required this.game});

  final OverTheBoardGame game;

  @override
  Widget build(BuildContext context) {
    final resultColor = game.winner == Side.white
        ? Colors.greenAccent
        : game.winner == Side.black
            ? Colors.redAccent
            : Colors.white54;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        onTap: () {
          Navigator.of(context, rootNavigator: true).push(
            OverTheBoardScreen.buildRoute(
              context,
              initialVariant: game.meta.variant,
              initialFen: game.initialFen,
            ),
          );
        },
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: resultColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Symbols.swords_rounded,
                color: resultColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${game.meta.variant.label} Game',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${game.steps.length} moves • ${game.status.name}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.play_arrow_rounded,
              color: Color(0xFFE8B84B),
            ),
          ],
        ),
      ),
    );
  }
}
