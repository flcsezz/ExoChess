import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:exochess_mobile/src/view/onboarding/onboarding_screen.dart' show kObRed, kObWhite, kObSurface;
import 'package:exochess_mobile/src/view/onboarding/widgets/monogram_rook_painter.dart';

/// Welcome page — collects the user's display name.
class WelcomePage extends StatefulWidget {
  const WelcomePage({
    super.key,
    required this.nameController,
    required this.onNext,
    this.onBack,
  });

  final TextEditingController nameController;
  final VoidCallback onNext;
  final VoidCallback? onBack;

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scale = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );
    _fade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final isKeyboardVisible = viewInsets.bottom > 100;

    return SingleChildScrollView(
      // Allows the page to scroll when the keyboard is visible,
      // eliminating the ~30-pixel overflow that occurs on the name-entry step.
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.only(
        left: 28,
        right: 28,
        bottom: viewInsets.bottom + 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isKeyboardVisible ? 24 : 40),

          // Animated monogram rook illustration — hidden when keyboard is up
          if (!isKeyboardVisible)
            Center(
              child: ScaleTransition(
                scale: _scale,
                child: const _RookIllustration(),
              ),
            ),

          SizedBox(height: isKeyboardVisible ? 0 : 40),

          // Headlines with staggered slide-in
          SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _fade,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi there,',
                    style: const TextStyle(
                      fontFamily: 'NDot',
                      fontSize: 14,
                      color: kObRed,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'What should\nwe call you?',
                    style: const TextStyle(
                      fontFamily: 'NDot',
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: kObWhite,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your name appears on the home screen.\nYou can skip this — no pressure.',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      color: kObWhite.withValues(alpha: 0.55),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Name input
          FadeTransition(
            opacity: _fade,
            child: TextField(
              controller: widget.nameController,
              style: GoogleFonts.outfit(color: kObWhite, fontSize: 16),
              cursorColor: kObRed,
              decoration: InputDecoration(
                hintText: 'Enter your name',
                hintStyle: GoogleFonts.outfit(
                  color: kObWhite.withValues(alpha: 0.3),
                ),
                filled: true,
                fillColor: kObSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: kObRed, width: 2),
                ),
                prefixIcon: Icon(
                  Icons.person_outline_rounded,
                  color: kObWhite.withValues(alpha: 0.4),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
              ),
              onSubmitted: (_) => widget.onNext(),
              textInputAction: TextInputAction.next,
            ),
          ),

          const SizedBox(height: 20),

          // Next CTA
          FadeTransition(
            opacity: _fade,
            child: Column(
              children: [
                _ObFilledButton(
                  label: 'Get Started →',
                  onPressed: widget.onNext,
                ),
                if (widget.onBack != null) ...[
                  const SizedBox(height: 12),
                  ObOutlinedButton(
                    label: '← Go Back',
                    onPressed: widget.onBack!,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Monogram Rook illustration ──────────────────────────────────────────────
class _RookIllustration extends StatefulWidget {
  const _RookIllustration();

  @override
  State<_RookIllustration> createState() => _RookIllustrationState();
}

class _RookIllustrationState extends State<_RookIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _float = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _float,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _float.value),
        child: SizedBox(
          width: 160,
          height: 160,
          child: CustomPaint(painter: const MonogramRookPainter()),
        ),
      ),
    );
  }
}

// ── Shared filled button ───────────────────────────────────────────────────
class ObFilledButton extends StatelessWidget {
  const ObFilledButton({super.key, required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => _ObFilledButton(label: label, onPressed: onPressed);
}

class _ObFilledButton extends StatelessWidget {
  const _ObFilledButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: kObRed,
          foregroundColor: kObWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceMono(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class ObOutlinedButton extends StatelessWidget {
  const ObOutlinedButton({super.key, required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.blueAccent.withValues(alpha: 0.4), width: 1.5),
          foregroundColor: Colors.blueAccent.withValues(alpha: 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceMono(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
