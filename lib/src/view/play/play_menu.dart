import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chessigma_mobile/src/styles/chessigma_colors.dart';
import 'package:chessigma_mobile/src/styles/styles.dart';
import 'package:chessigma_mobile/src/utils/l10n_context.dart';
import 'package:chessigma_mobile/src/view/board_editor/board_editor_screen.dart';
import 'package:chessigma_mobile/src/view/offline_computer/offline_computer_game_screen.dart';
import 'package:chessigma_mobile/src/view/over_the_board/over_the_board_screen.dart';
import 'package:chessigma_mobile/src/widgets/cyberpunk/cyberpunk.dart';
import 'package:material_symbols_icons/symbols.dart';

class PlayMenu extends StatelessWidget {
  const PlayMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Styles.bodySectionPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PlayOptionCard(
            title: context.l10n.playAgainstComputer,
            subtitle: 'Challenge the engine at your level',
            icon: Symbols.memory_rounded,
            glowColor: const Color(0xFFE8B84B), // Gold
            onTap: () {
              Navigator.of(context).popUntil((route) => route is! ModalBottomSheetRoute);
              Navigator.of(context, rootNavigator: true).push(OfflineComputerGameScreen.buildRoute(context));
            },
          ),
          const SizedBox(height: 16),
          _PlayOptionCard(
            title: context.l10n.mobileOverTheBoard,
            subtitle: 'Play with a friend locally',
            icon: Symbols.swords_rounded,
            glowColor: const Color(0xFFE8B84B), // Gold
            onTap: () {
              Navigator.of(context).popUntil((route) => route is! ModalBottomSheetRoute);
              Navigator.of(context, rootNavigator: true).push(OverTheBoardScreen.buildRoute(context));
            },
          ),
          const SizedBox(height: 16),
          _PlayOptionCard(
            title: 'Over The Board (Custom)',
            subtitle: 'Set up your own position and play',
            icon: Symbols.dashboard_customize_rounded,
            glowColor: const Color(0xFFE8B84B), // Gold
            onTap: () {
              Navigator.of(context).popUntil((route) => route is! ModalBottomSheetRoute);
              Navigator.of(context, rootNavigator: true).push(BoardEditorScreen.buildRoute(context, null));
            },
          ),
        ],
      ),
    );
  }
}

class _PlayOptionCard extends StatelessWidget {
  const _PlayOptionCard({
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
          border: Border.all(color: glowColor.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: glowColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.2),
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
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
