import 'package:dartchess/dartchess.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chessigma_mobile/src/model/analysis/analysis_controller.dart';
import 'package:chessigma_mobile/src/model/common/chess.dart';
import 'package:chessigma_mobile/src/network/connectivity.dart';
import 'package:chessigma_mobile/src/styles/styles.dart';
import 'package:chessigma_mobile/src/utils/l10n_context.dart';
import 'package:chessigma_mobile/src/view/account/account_drawer.dart';
import 'package:chessigma_mobile/src/view/analysis/analysis_screen.dart';
import 'package:chessigma_mobile/src/view/board_editor/board_editor_screen.dart';
import 'package:chessigma_mobile/src/view/clock/clock_tool_screen.dart';
import 'package:chessigma_mobile/src/view/explorer/opening_explorer_screen.dart';
import 'package:chessigma_mobile/src/view/more/import_pgn_screen.dart';
import 'package:chessigma_mobile/src/widgets/list.dart';
import 'package:chessigma_mobile/src/widgets/misc.dart';
import 'package:chessigma_mobile/src/widgets/platform.dart';
import 'package:chessigma_mobile/src/widgets/settings.dart';

class MoreTabScreen extends ConsumerWidget {
  const MoreTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(connectivityChangesProvider).value?.isOnline ?? true;

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(context.l10n.more),
        leading: const SettingsIconButton(),
      ),
      body: ListView(
        children: [
          ListSection(
            header: SettingsSectionTitle(context.l10n.puzzles),
            hasLeading: true,
            children: [
              ListTile(
                leading: const Icon(Icons.auto_graph),
                title: const Text('Puzzles Dashboard'), // TODO: l10n
                enabled: isOnline,
                trailing: Theme.of(context).platform == TargetPlatform.iOS
                    ? const CupertinoListTileChevron()
                    : null,
                onTap: () {
                  // TODO
                },
              ),
            ],
          ),
          ListSection(
            header: SettingsSectionTitle(context.l10n.tools),
            hasLeading: true,
            children: [
              ListTile(
                leading: const Icon(Icons.analytics_outlined),
                title: Text(context.l10n.analysis),
                trailing: Theme.of(context).platform == TargetPlatform.iOS
                    ? const CupertinoListTileChevron()
                    : null,
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    AnalysisScreen.buildRoute(
                      context,
                      const AnalysisOptions.standalone(
                        variant: Variant.standard,
                        orientation: Side.white,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_note),
                title: Text(context.l10n.boardEditor),
                trailing: Theme.of(context).platform == TargetPlatform.iOS
                    ? const CupertinoListTileChevron()
                    : null,
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    BoardEditorScreen.buildRoute(
                      context,
                      const (initialVariant: Variant.standard, initialFen: null),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.upload_file_outlined),
                title: Text(context.l10n.importPgn),
                trailing: Theme.of(context).platform == TargetPlatform.iOS
                    ? const CupertinoListTileChevron()
                    : null,
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(ImportPgnScreen.buildRoute(context));
                },
              ),
              ListTile(
                leading: const Icon(Icons.explore_outlined),
                title: Text(context.l10n.openingExplorer),
                trailing: Theme.of(context).platform == TargetPlatform.iOS
                    ? const CupertinoListTileChevron()
                    : null,
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    OpeningExplorerScreen.buildRoute(
                      context,
                      const AnalysisOptions.standalone(
                        variant: Variant.standard,
                        orientation: Side.white,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.hourglass_bottom_outlined),
                title: const Text('Chess Clock'), // TODO: l10n
                trailing: Theme.of(context).platform == TargetPlatform.iOS
                    ? const CupertinoListTileChevron()
                    : null,
                onTap: () {
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).push(ClockToolScreen.buildRoute(context));
                },
              ),
            ],
          ),
          Padding(
            padding: Styles.bodySectionPadding,
            child: ChessigmaMessage(style: TextTheme.of(context).bodyMedium),
          ),
        ],
      ),
    );
  }
}
