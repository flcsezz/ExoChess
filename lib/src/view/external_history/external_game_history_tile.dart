import 'package:dartchess/dartchess.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:chessigma_mobile/src/model/analysis/analysis_controller.dart';
import 'package:chessigma_mobile/src/model/external_history/external_history.dart';
import 'package:chessigma_mobile/src/model/game/game_status.dart';
import 'package:chessigma_mobile/src/styles/chessigma_colors.dart';
import 'package:chessigma_mobile/src/styles/styles.dart';
import 'package:chessigma_mobile/src/view/analysis/analysis_screen.dart';

final _dateFormatter = DateFormat.yMMMd().add_Hm();

class ExternalGameHistoryTile extends StatelessWidget {
  const ExternalGameHistoryTile({
    required this.item,
    super.key,
  });

  final ExternalGameHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final pov = item.orientationForUsername(item.username) ?? Side.white;
    final opponent = pov == Side.white ? item.players.black : item.players.white;

    Widget getResultIcon() {
      if (item.status == GameStatus.aborted || item.status == GameStatus.noStart) {
        return const Icon(CupertinoIcons.xmark_square_fill, color: ChessigmaColors.grey);
      } else {
        return item.winner == null
            ? Icon(CupertinoIcons.equal_square_fill, color: context.chessigmaColors.brag)
            : item.winner == pov
                ? Icon(CupertinoIcons.plus_square_fill, color: context.chessigmaColors.good)
                : Icon(CupertinoIcons.minus_square_fill, color: context.chessigmaColors.error);
      }
    }

    return ListTile(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          AnalysisScreen.buildRoute(
            context,
            AnalysisOptions.pgn(
              id: item.analysisId,
              orientation: pov,
              pgn: item.pgn,
              variant: item.variant,
              isComputerAnalysisAllowed: true,
            ),
          ),
        );
      },
      leading: Icon(item.perf.icon),
      title: Text(opponent.name ?? 'Anonymous'),
      subtitle: Text(_dateFormatter.format(item.createdAt)),
      trailing: getResultIcon(),
    );
  }
}
