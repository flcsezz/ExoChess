import 'package:flutter/material.dart';
import 'package:exochess_mobile/src/view/onboarding/onboarding_screen.dart' show kObWhite;

/// Animated pill-based page progress indicator.
class OnboardingProgress extends StatelessWidget {
  const OnboardingProgress({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.accentColor,
  });

  final int currentPage;
  final int totalPages;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? accentColor
                : kObWhite.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(50),
          ),
        );
      }),
    );
  }
}
