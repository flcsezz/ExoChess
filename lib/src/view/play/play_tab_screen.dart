import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exochess_mobile/src/styles/styles.dart';
import 'package:exochess_mobile/src/view/account/account_drawer.dart';
import 'package:exochess_mobile/src/view/play/play_menu.dart';
import 'package:exochess_mobile/src/view/over_the_board/otb_history_screen.dart';
import 'package:exochess_mobile/src/widgets/platform.dart';

class PlayTabScreen extends ConsumerWidget {
  const PlayTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return DefaultTabController(
      length: 2,
      child: PlatformScaffold(
        appBar: PlatformAppBar(
          title: const Text('PLAY', style: TextStyle(fontFamily: 'NDot', fontSize: 20)),
          centerTitle: true,
          leading: const SettingsIconButton(),
          bottom: TabBar(
            dividerColor: Colors.transparent,
            indicatorColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontFamily: 'SpaceMono', fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [
              Tab(text: 'NEW GAME'.toUpperCase()),
              Tab(text: 'OTB HISTORY'.toUpperCase()),
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
