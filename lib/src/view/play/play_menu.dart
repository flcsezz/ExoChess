import 'package:flutter/material.dart';
import 'package:chessigma_mobile/src/utils/l10n_context.dart';
import 'package:chessigma_mobile/src/view/offline_computer/offline_computer_game_screen.dart';
import 'package:chessigma_mobile/src/view/over_the_board/over_the_board_screen.dart';
import 'package:chessigma_mobile/src/widgets/list.dart';

class PlayMenu extends StatelessWidget {
  const PlayMenu();

  @override
  Widget build(BuildContext context) {
    return _Section(
      children: [
        ListTile(
          onTap: () {
            Navigator.of(context).popUntil((route) => route is! ModalBottomSheetRoute);
            Navigator.of(
              context,
              rootNavigator: true,
            ).push(OfflineComputerGameScreen.buildRoute(context));
          },
          leading: const Icon(Icons.memory),
          title: Text(context.l10n.playAgainstComputer),
        ),
        ListTile(
          onTap: () {
            Navigator.of(context).popUntil((route) => route is! ModalBottomSheetRoute);
            Navigator.of(
              context,
              rootNavigator: true,
            ).push(OverTheBoardScreen.buildRoute(context));
          },
          leading: const Icon(Icons.table_restaurant_outlined),
          title: Text(context.l10n.mobileOverTheBoard),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListSection(hasLeading: true, materialFilledCard: true, children: children);
  }
}
