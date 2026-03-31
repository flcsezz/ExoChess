import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:exochess_mobile/src/view/onboarding/onboarding_screen.dart' show kObRed, kObWhite, kObSurface;
import 'package:exochess_mobile/src/view/onboarding/pages/welcome_page.dart' show ObFilledButton, ObOutlinedButton;

/// The final page — personalised CTA with celebration burst.
class FinishPage extends StatefulWidget {
  const FinishPage({
    super.key,
    required this.displayName,
    required this.onFinish,
    required this.onBack,
  });

  final String displayName;
  final VoidCallback onFinish;
  final VoidCallback onBack;

  @override
  State<FinishPage> createState() => _FinishPageState();
}

class _FinishPageState extends State<FinishPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _burst;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _burst = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
    );
    _fade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.35, 0.85, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic),
    ));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String get _greeting {
    final name = widget.displayName.trim();
    return name.isEmpty ? 'Welcome,\nChampion!' : 'Welcome,\n$name!';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // Burst celebration ring
          ScaleTransition(
            scale: _burst,
            child: const _CelebrationRing(),
          ),

          const SizedBox(height: 40),

          // Greeting text
          SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _fade,
              child: Column(
                children: [
                  Text(
                    _greeting,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'NDot',
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: kObWhite,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your chess journey starts now.\nEvery move is a lesson.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: kObWhite.withValues(alpha: 0.55),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(flex: 1),

          // Feature summary chips
          FadeTransition(
            opacity: _fade,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: const [
                _SummaryChip(icon: Icons.sports_esports_rounded, label: 'Play'),
                _SummaryChip(icon: Icons.extension_rounded, label: 'Puzzles'),
                _SummaryChip(icon: Icons.query_stats_rounded, label: 'Analysis'),
                _SummaryChip(icon: Icons.school_rounded, label: 'Learn'),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Get started CTA
          FadeTransition(
            opacity: _fade,
            child: Column(
              children: [
                ObFilledButton(
                  label: "Let's Play →",
                  onPressed: widget.onFinish,
                ),
                const SizedBox(height: 12),
                ObOutlinedButton(
                  label: '← Prev Step',
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

// ── Celebration ring ──────────────────────────────────────────────────────
class _CelebrationRing extends StatefulWidget {
  const _CelebrationRing();

  @override
  State<_CelebrationRing> createState() => _CelebrationRingState();
}

class _CelebrationRingState extends State<_CelebrationRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotCtrl;

  @override
  void initState() {
    super.initState();
    _rotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _rotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: AnimatedBuilder(
        animation: _rotCtrl,
        builder: (_, __) => CustomPaint(
          painter: _CelebrationRingPainter(rotation: _rotCtrl.value),
        ),
      ),
    );
  }
}

class _CelebrationRingPainter extends CustomPainter {
  _CelebrationRingPainter({required this.rotation});
  final double rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation * 2 * math.pi);
    canvas.translate(-center.dx, -center.dy);

    for (int i = 0; i < 24; i++) {
      final angle = (i / 24) * 2 * math.pi;
      final opacity = (i % 3 == 0) ? 1.0 : 0.25;
      final r = radius * 0.96 * (1.02 + 0.05 * (i % 2));
      final dotX = center.dx + r * math.sin(angle);
      final dotY = center.dy - r * math.cos(angle);
      canvas.drawCircle(
        Offset(dotX, dotY),
        i % 3 == 0 ? 3.5 : 2.0,
        Paint()..color = kObRed.withValues(alpha: opacity),
      );
    }
    canvas.restore();

    // Inner glow
    canvas.drawCircle(
      center,
      radius * 0.75,
      Paint()
        ..color = kObRed.withValues(alpha: 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    // King crown at center
    _drawKingCrown(canvas, center, radius * 0.38);
  }

  void _drawKingCrown(Canvas canvas, Offset center, double s) {
    final paint = Paint()
      ..color = kObRed
      ..style = PaintingStyle.fill;

    // Cross
    final crossH = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: s * 0.7, height: s * 0.22),
      const Radius.circular(4),
    );
    final crossV = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - s * 0.1),
        width: s * 0.22,
        height: s * 0.7,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(crossH, paint);
    canvas.drawRRect(crossV, paint);

    // Base bar
    final base = Path()
      ..moveTo(center.dx - s * 0.45, center.dy + s * 0.32)
      ..lineTo(center.dx + s * 0.45, center.dy + s * 0.32)
      ..lineTo(center.dx + s * 0.38, center.dy + s * 0.52)
      ..lineTo(center.dx - s * 0.38, center.dy + s * 0.52)
      ..close();
    canvas.drawPath(base, paint);
  }

  @override
  bool shouldRepaint(_CelebrationRingPainter old) => old.rotation != rotation;
}

// ── Summary chip ──────────────────────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: kObSurface,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: kObWhite.withValues(alpha: 0.1), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: kObWhite.withValues(alpha: 0.7)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: kObWhite.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
