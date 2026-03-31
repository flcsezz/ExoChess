import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exochess_mobile/src/model/onboarding/onboarding_preferences.dart';
import 'package:exochess_mobile/src/view/onboarding/pages/welcome_page.dart';
import 'package:exochess_mobile/src/view/onboarding/models.dart';
import 'package:exochess_mobile/src/view/onboarding/pages/feature_page.dart';
import 'package:exochess_mobile/src/view/onboarding/pages/finish_page.dart';
import 'package:exochess_mobile/src/view/onboarding/widgets/onboarding_progress.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Design tokens ──────────────────────────────────────────────────────────
const kObRed = Color(0xFFD71921);
const kObBlack = Color(0xFF000000);
const kObSurface = Color(0xFF111111);
const kObSurfaceHigh = Color(0xFF1B1B1D);
const kObWhite = Color(0xFFFFFFFF);

const _pageCount = 6; // welcome + 4 feature + finish

// ── Feature slide data ─────────────────────────────────────────────────────
const _slides = [
  FeatureSlideData(
    id: 'play',
    title: 'Play Your Way',
    subtitle: 'Challenge AI at any level or pass-and-play with a friend over the board.',
    accentColor: Color(0xFFD71921),
    illustrationType: IllustrationType.play,
  ),
  FeatureSlideData(
    id: 'puzzles',
    title: 'Sharpen Tactics',
    subtitle: 'Train with thousands of rated puzzles sourced from real grandmaster games.',
    accentColor: Color(0xFFFF6B35),
    illustrationType: IllustrationType.puzzles,
  ),
  FeatureSlideData(
    id: 'analysis',
    title: 'Deep Analysis',
    subtitle: 'Review every game with live Stockfish evaluation and move quality badges — Brilliant to Blunder.',
    accentColor: Color(0xFF7C4DFF),
    illustrationType: IllustrationType.analysis,
  ),
  FeatureSlideData(
    id: 'learn',
    title: 'Learn & Explore',
    subtitle: 'Study openings interactively and master board coordinates with guided training.',
    accentColor: Color(0xFF00BCD4),
    illustrationType: IllustrationType.learn,
    disclaimer: 'Opening Explorer requires a Lichess account. Sign in from the More tab.',
  ),
];

// ── OnboardingScreen ───────────────────────────────────────────────────────
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  final _nameController = TextEditingController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (_currentPage < _pageCount - 1) {
      setState(() => _currentPage++);
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubicEmphasized,
      );
    }
  }

  void _back() {
    FocusScope.of(context).unfocus();
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubicEmphasized,
      );
    }
  }

  void _skip() {
    ref.read(onboardingPreferencesProvider.notifier).skip();
  }

  void _finish() {
    final name = _nameController.text.trim();
    ref.read(onboardingPreferencesProvider.notifier).complete(
      displayName: name.isEmpty ? null : name,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Animate background accent based on current page
    final accentColor = _currentPage == 0
        ? kObRed
        : _currentPage == _pageCount - 1
            ? kObRed
            : _slides[_currentPage - 1].accentColor;

    return Scaffold(
      backgroundColor: kObBlack,
      body: Stack(
        children: [
          // Animated radial background glow
          _AnimatedBackground(accentColor: accentColor, page: _currentPage),

          // Main page content
          SafeArea(
            child: Column(
              children: [
                // Top bar: Skip + Logo
                _TopBar(
                  currentPage: _currentPage,
                  totalPages: _pageCount,
                  onSkip: _currentPage < _pageCount - 1 ? _skip : null,
                ),

                // Page view
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                        WelcomePage(
                          nameController: _nameController,
                          onNext: _next,
                        ),
                        ..._slides.map(
                          (slide) => FeaturePage(
                            slide: slide,
                            onNext: _next,
                            onBack: _back,
                          ),
                        ),
                        FinishPage(
                          displayName: _nameController.text.trim(),
                          onFinish: _finish,
                          onBack: _back,
                        ),
                    ],
                  ),
                ),

                // Progress indicator dots
                Padding(
                  padding: const EdgeInsets.only(bottom: 32, top: 16),
                  child: OnboardingProgress(
                    currentPage: _currentPage,
                    totalPages: _pageCount,
                    accentColor: accentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top bar ────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.currentPage,
    required this.totalPages,
    this.onSkip,
  });

  final int currentPage;
  final int totalPages;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App wordmark
          Text(
            'ExoChess',
            style: TextStyle(
              fontFamily: 'NDot',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kObWhite,
              letterSpacing: 0.5,
            ),
          ),
          // Skip button (hidden on last page)
          AnimatedOpacity(
            opacity: onSkip != null ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                foregroundColor: kObWhite.withValues(alpha: 0.6),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Skip',
                style: GoogleFonts.spaceMono(
                  fontSize: 13,
                  color: kObWhite.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated background gradient glow ─────────────────────────────────────
class _AnimatedBackground extends StatefulWidget {
  const _AnimatedBackground({required this.accentColor, required this.page});
  final Color accentColor;
  final int page;

  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Color?> _colorAnim;
  Color _prevColor = kObRed;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _colorAnim = ColorTween(begin: widget.accentColor, end: widget.accentColor)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_AnimatedBackground old) {
    super.didUpdateWidget(old);
    if (old.accentColor != widget.accentColor) {
      _prevColor = old.accentColor;
      _colorAnim = ColorTween(begin: _prevColor, end: widget.accentColor)
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnim,
      builder: (context, _) {
        final color = _colorAnim.value ?? widget.accentColor;
        return CustomPaint(
          painter: _GlowPainter(color: color),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _GlowPainter extends CustomPainter {
  _GlowPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Top-left radial glow
    final paint1 = Paint()
      ..shader = RadialGradient(
        center: Alignment.topLeft,
        radius: 1.0,
        colors: [
          color.withValues(alpha: 0.18),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width * 1.4, size.height * 0.9));
    canvas.drawRect(Offset.zero & size, paint1);

    // Bottom-right subtle glow
    final paint2 = Paint()
      ..shader = RadialGradient(
        center: Alignment.bottomRight,
        radius: 0.8,
        colors: [
          color.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Offset.zero & size, paint2);
  }

  @override
  bool shouldRepaint(_GlowPainter old) => old.color != color;
}
