import 'package:flutter/material.dart';

/// Animated splash screen shown while the app initializes.
///
/// Plays a staggered animation:
/// 1. Background fades in (0–300 ms)
/// 2. Logo scales + fades in (300–800 ms)
/// 3. Wordmark slides up + fades in (600–1000 ms)
/// 4. Tagline fades in (900–1200 ms)
/// 5. Sigma particle burst (800–1400 ms)
///
/// The widget stays visible until [isReady] becomes true, then fades out.
class ChessigmaSplashScreen extends StatefulWidget {
  const ChessigmaSplashScreen({
    super.key,
    required this.isReady,
    required this.child,
  });

  final bool isReady;
  final Widget child;

  @override
  State<ChessigmaSplashScreen> createState() => _ChessigmaSplashScreenState();
}

class _ChessigmaSplashScreenState extends State<ChessigmaSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _exitCtrl;
  late final Animation<double> _exitOpacity;

  bool _showSplash = true;

  @override
  void initState() {
    super.initState();

    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn),
    );

    if (widget.isReady) {
      _runExit();
    }
  }

  @override
  void didUpdateWidget(ChessigmaSplashScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isReady && !oldWidget.isReady) {
      _runExit();
    }
  }

  Future<void> _runExit() async {
    await _exitCtrl.forward();
    if (mounted) {
      setState(() => _showSplash = false);
    }
  }

  @override
  void dispose() {
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showSplash) return widget.child;

    return Stack(
      children: [
        widget.child,
        FadeTransition(
          opacity: _exitOpacity,
          child: const _SplashContent(),
        ),
      ],
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  static const _bgDark = Color(0xFF0A0E1A);
  static const _gold = Color(0xFFE8B84B);
  static const _goldLight = Color(0xFFF5CC72);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _bgDark,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/chessigma-logo.png',
              width: 140,
              height: 140,
            ),
            const SizedBox(height: 24),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [_goldLight, _gold],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(bounds),
              child: const Text(
                'Chessigma',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 1, color: _gold.withAlpha(128)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'Σ',
                    style: TextStyle(color: _gold, fontSize: 18, height: 1),
                  ),
                ),
                Container(width: 40, height: 1, color: _gold.withAlpha(128)),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Play. Analyze. Master.',
              style: TextStyle(
                color: Colors.white.withAlpha(178),
                fontSize: 13,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
