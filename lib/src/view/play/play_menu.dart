import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:exochess_mobile/src/styles/exochess_colors.dart';
import 'package:exochess_mobile/src/styles/styles.dart';
import 'package:exochess_mobile/src/utils/l10n_context.dart';
import 'package:exochess_mobile/src/view/board_editor/board_editor_screen.dart';
import 'package:exochess_mobile/src/view/offline_computer/offline_computer_game_screen.dart';
import 'package:exochess_mobile/src/view/over_the_board/over_the_board_screen.dart';
import 'package:exochess_mobile/src/widgets/cyberpunk/cyberpunk.dart';
import 'package:material_symbols_icons/symbols.dart';

class PlayMenu extends StatelessWidget {
  const PlayMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: Styles.bodySectionPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 24.0),
            child: Text(
              'PLAY CHESS',
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: 'NDot',
                fontSize: 24,
                letterSpacing: 2.0,
              ),
            ),
          ),
          _PlayOptionCard(
            title: context.l10n.playAgainstComputer.toUpperCase(),
            subtitle: 'CHALLENGE THE ENGINE AT YOUR LEVEL',
            icon: Symbols.memory_rounded,
            onTap: () {
              Navigator.of(context).popUntil((route) => route is! ModalBottomSheetRoute);
              Navigator.of(context, rootNavigator: true).push(OfflineComputerGameScreen.buildRoute(context));
            },
          ),
          const SizedBox(height: 16),
          _PlayOptionCard(
            title: context.l10n.mobileOverTheBoard.toUpperCase(),
            subtitle: 'PLAY WITH A FRIEND LOCALLY',
            icon: Symbols.swords_rounded,
            onTap: () {
              Navigator.of(context).popUntil((route) => route is! ModalBottomSheetRoute);
              Navigator.of(context, rootNavigator: true).push(OverTheBoardScreen.buildRoute(context));
            },
          ),
          const SizedBox(height: 16),
          _PlayOptionCard(
            title: 'OVER THE BOARD (CUSTOM)',
            subtitle: 'SET UP YOUR OWN POSITION AND PLAY',
            icon: Symbols.dashboard_customize_rounded,
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
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.primary;

    return Card(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(icon, color: accentColor, size: 32),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFamily: 'SpaceMono',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontFamily: 'SpaceMono',
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
