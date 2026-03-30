import 'package:dartchess/dartchess.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:chessigma_mobile/src/widgets/cyberpunk/glass_card.dart';
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MoreCard(
              title: context.l10n.importPgn,
              subtitle: 'Import and analyze PGN files',
              icon: Icons.upload_file_outlined,
              glowColor: const Color(0xFFE8B84B),
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(ImportPgnScreen.buildRoute(context));
              },
            ),
            const SizedBox(height: 16),
            _MoreCard(
              title: context.l10n.openingExplorer,
              subtitle: 'Master the openings with Lichess DB',
              icon: Icons.explore_outlined,
              glowColor: const Color(0xFFE8B84B),
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
            const SizedBox(height: 16),
            _MoreCard(
              title: context.l10n.analysis,
              subtitle: 'Free-form analysis with engine',
              icon: Icons.analytics_outlined,
              glowColor: const Color(0xFFE8B84B),
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
            const SizedBox(height: 16),
            _MoreCard(
              title: context.l10n.boardEditor,
              subtitle: 'Set up custom positions',
              icon: Icons.dashboard_customize_outlined,
              glowColor: const Color(0xFFE8B84B),
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(BoardEditorScreen.buildRoute(context, null));
              },
            ),
            const SizedBox(height: 16),
            _MoreCard(
              title: 'Chess Clock',
              subtitle: 'Professional clock for OTB games',
              icon: Icons.hourglass_bottom_outlined,
              glowColor: const Color(0xFFE8B84B),
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(ClockToolScreen.buildRoute(context));
              },
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: ChessigmaMessage(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreCard extends StatelessWidget {
  const _MoreCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.glowColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color glowColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: glowColor.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: glowColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.1),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(icon, color: glowColor, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ],
        ),
      ),
    );
  }
}
