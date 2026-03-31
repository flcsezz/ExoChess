import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:exochess_mobile/src/view/onboarding/models.dart';
import 'package:exochess_mobile/src/view/onboarding/onboarding_screen.dart' show kObWhite;
import 'package:exochess_mobile/src/view/onboarding/pages/welcome_page.dart' show ObFilledButton, ObOutlinedButton;
import 'package:exochess_mobile/src/view/onboarding/widgets/feature_illustration.dart';

// ── Data model for feature slides ─────────────────────────────────────────

class FeatureSlideData {
  const FeatureSlideData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.illustrationType,
    this.disclaimer,
  });

  final String id;
  final String title;
  final String subtitle;
  final Color accentColor;
  final IllustrationType illustrationType;
  final String? disclaimer;
}

// ── Feature page ──────────────────────────────────────────────────────────
class FeaturePage extends StatefulWidget {
  const FeaturePage({super.key, required this.slide, required this.onNext, required this.onBack});
  final FeatureSlideData slide;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  State<FeaturePage> createState() => _FeaturePageState();
}

class _FeaturePageState extends State<FeaturePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slideUp;
  late final Animation<double> _illustrationScale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _fade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.3, 0.9, curve: Curves.easeOut),
    );
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.2, 0.85, curve: Curves.easeOutCubic),
    ));
    _illustrationScale = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.65, curve: Curves.elasticOut),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = widget.slide;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 1),

          // Illustration
          Center(
            child: ScaleTransition(
              scale: _illustrationScale,
              child: FeatureIllustration(
                type: slide.illustrationType,
                accentColor: slide.accentColor,
                size: 200,
              ),
            ),
          ),

          const SizedBox(height: 44),

          // Text content
          SlideTransition(
            position: _slideUp,
            child: FadeTransition(
              opacity: _fade,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Accent chip label
                  _AccentChip(
                    color: slide.accentColor,
                    label: slide.illustrationType.name.toUpperCase(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    slide.title,
                    style: TextStyle(
                      fontFamily: 'NDot',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: kObWhite,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    slide.subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      color: kObWhite.withValues(alpha: 0.6),
                      height: 1.6,
                    ),
                  ),

                  // Disclaimer banner (Learn slide only)
                  if (slide.disclaimer != null) ...[
                    const SizedBox(height: 16),
                    _DisclaimerBanner(text: slide.disclaimer!),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Next CTA
          FadeTransition(
            opacity: _fade,
            child: Column(
              children: [
                ObFilledButton(
                  label: 'Next →',
                  onPressed: widget.onNext,
                ),
                const SizedBox(height: 12),
                ObOutlinedButton(
                  label: '← Previous',
                  onPressed: widget.onBack,
                ),
              ],
            ),
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

// ── Accent chip ───────────────────────────────────────────────────────────
class _AccentChip extends StatelessWidget {
  const _AccentChip({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.spaceMono(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

// ── Disclaimer banner ────────────────────────────────────────────────────
class _DisclaimerBanner extends StatelessWidget {
  const _DisclaimerBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF00BCD4).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00BCD4).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF00BCD4),
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: const Color(0xFF00BCD4).withValues(alpha: 0.9),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
