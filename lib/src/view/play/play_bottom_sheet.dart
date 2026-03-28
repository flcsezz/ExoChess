import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chessigma_mobile/src/styles/chessigma_colors.dart';
import 'package:chessigma_mobile/src/utils/l10n_context.dart';
import 'package:chessigma_mobile/src/view/play/play_menu.dart';
import 'package:chessigma_mobile/src/widgets/adaptive_bottom_sheet.dart';
import 'package:material_symbols_icons/symbols.dart';

class FloatingPlayButton extends ConsumerWidget {
  const FloatingPlayButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: ChessigmaColors.neonGold.withOpacity(0.5),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        backgroundColor: ChessigmaColors.voidBackgroundLighter,
        foregroundColor: ChessigmaColors.neonGold,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: const BorderSide(color: ChessigmaColors.neonGold, width: 1.5),
        ),
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            useRootNavigator: true,
            isScrollControlled: true,
            builder: (context) => const PlayBottomSheet(),
          );
        },
        tooltip: context.l10n.play,
        icon: const Icon(Symbols.chess_pawn_rounded),
        label: Text(
          context.l10n.play,
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
    );
  }
}

class PlayBottomSheet extends ConsumerWidget {
  const PlayBottomSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const BottomSheetScrollableContainer(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      children: [PlayMenu()],
    );
  }
}
