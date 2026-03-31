import 'package:exochess_mobile/src/styles/styles.dart';
import 'package:flutter/material.dart';

class SmallVectorCard extends StatelessWidget {
  const SmallVectorCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.enabled = true,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.primary;

    return Card(
      elevation: 0,
      color: isDark ? null : Colors.white,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: Styles.cardBorderRadius,
        child: Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: Container(
            height: 120,
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Opacity(
                    opacity: isDark ? 0.05 : 0.03,
                    child: Icon(icon, size: 80, color: accentColor),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: accentColor, size: 24),
                    const SizedBox(height: 12),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'NDot', 
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 9,
                        color: isDark ? Colors.white38 : Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VectorHeader extends StatelessWidget {
  const VectorHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    super.key,
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
      elevation: 0,
      color: isDark ? null : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: Styles.cardBorderRadius,
        child: Container(
          height: 160,
          padding: const EdgeInsets.all(24),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Opacity(
                  opacity: isDark ? 0.1 : 0.05,
                  child: Icon(icon, size: 140, color: accentColor),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                      border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                    ),
                    child: Icon(icon, color: accentColor, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'NDot', 
                          fontSize: 20,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'SpaceMono',
                      fontSize: 11,
                      color: isDark ? Colors.white38 : Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
