import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chessigma_mobile/src/styles/styles.dart';
import 'package:chessigma_mobile/src/view/play/play_menu.dart';
import 'package:chessigma_mobile/src/view/over_the_board/otb_history_screen.dart';
import 'package:chessigma_mobile/src/widgets/platform.dart';

class PlayTabScreen extends ConsumerWidget {
  const PlayTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: PlatformScaffold(
        appBar: PlatformAppBar(
          title: const Text('Play'),
          bottom: const TabBar(
            indicatorColor: Color(0xFFE8B84B),
            labelColor: Color(0xFFE8B84B),
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'New Game'),
              Tab(text: 'OTB History'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SingleChildScrollView(child: PlayMenu()),
            OtbHistoryScreen(),
          ],
        ),
      ),
    );
  }
}
