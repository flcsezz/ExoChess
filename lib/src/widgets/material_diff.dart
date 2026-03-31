import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:exochess_mobile/src/model/game/material_diff.dart';
import 'package:exochess_mobile/src/model/settings/board_preferences.dart';
import 'package:exochess_mobile/src/styles/exochess_icons.dart';
import 'package:exochess_mobile/src/styles/styles.dart';
import 'package:exochess_mobile/src/utils/screen.dart';

class MaterialDifferenceDisplay extends StatelessWidget {
  const MaterialDifferenceDisplay({
    required this.materialDiff,
    this.materialDifferenceFormat = MaterialDifferenceFormat.materialDifference,
  });

  final MaterialDiffSide? materialDiff;
  final MaterialDifferenceFormat? materialDifferenceFormat;

  static const _iconByRole = {
    Role.king: ExoChessIcons.chess_king,
    Role.queen: ExoChessIcons.chess_queen,
    Role.rook: ExoChessIcons.chess_rook,
    Role.bishop: ExoChessIcons.chess_bishop,
    Role.knight: ExoChessIcons.chess_knight,
    Role.pawn: ExoChessIcons.chess_pawn,
  };

  @override
  Widget build(BuildContext context) {
    // Show captured pieces if format is capturedPieces OR if it's OTB/Analysis (handled by passing this format)
    // We want to show the full captured set, so we use materialDiff.capturedPieces
    final IMap<Role, int> piecesToRender = materialDiff?.capturedPieces ?? IMap();

    final isShortScreen = isShortVerticalScreen(context);
    final iconSize = isShortScreen ? 11.0 : 13.0;
    final textSize = isShortScreen ? 12.0 : 14.0;

    Icon roleIcon(Role role) =>
        Icon(_iconByRole[role], size: iconSize, color: textShade(context, 0.5));

    if (!(materialDifferenceFormat?.visible ?? true)) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Captured pieces icons
        for (final role in Role.values)
          for (int i = 0; i < (piecesToRender.get(role) ?? 0); i++) 
            Padding(
              padding: const EdgeInsets.only(right: 1),
              child: roleIcon(role),
            ),
        
        if (piecesToRender.isNotEmpty && materialDiff != null && materialDiff!.score > 0)
          const SizedBox(width: 4),

        // Score difference
        if (materialDiff != null && materialDiff!.score > 0)
          Text(
            '+${materialDiff!.score}',
            style: TextStyle(
              fontSize: textSize, 
              color: textShade(context, 0.5),
              fontWeight: FontWeight.bold,
            ),
          ),

        if (materialDiff?.checksGiven != null) ...[
          const SizedBox(width: 6),
          ...Iterable.generate(materialDiff?.checksGiven ?? 0, (_) => roleIcon(Role.king)),
        ],
      ],
    );
  }
}
