import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:exochess_mobile/src/view/onboarding/models.dart';

/// Animated Material 3 illustration for each feature slide.
class FeatureIllustration extends StatelessWidget {
  const FeatureIllustration({
    super.key,
    required this.type,
    required this.accentColor,
    required this.size,
  });

  final IllustrationType type;
  final Color accentColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: switch (type) {
        IllustrationType.play => _PlayIllustration(accentColor: accentColor),
        IllustrationType.puzzles => _PuzzleIllustration(accentColor: accentColor),
        IllustrationType.analysis => _AnalysisIllustration(accentColor: accentColor),
        IllustrationType.learn => _LearnIllustration(accentColor: accentColor),
      },
    );
  }
}


// ── Play Illustration — chessboard with AI chip ────────────────────────────
class _PlayIllustration extends StatefulWidget {
  const _PlayIllustration({required this.accentColor});
  final Color accentColor;

  @override
  State<_PlayIllustration> createState() => _PlayIllustrationState();
}

class _PlayIllustrationState extends State<_PlayIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.93, end: 1.07)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => CustomPaint(
        painter: _PlayPainter(accentColor: widget.accentColor, pulse: _pulse.value),
      ),
    );
  }
}

class _PlayPainter extends CustomPainter {
  _PlayPainter({required this.accentColor, required this.pulse});
  final Color accentColor;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final boardSize = size.width * 0.7;
    final sq = boardSize / 4;
    final boardLeft = cx - boardSize / 2;
    final boardTop = cy - boardSize / 2;

    // Board shadow glow
    canvas.drawCircle(
      Offset(cx, cy),
      boardSize * 0.65,
      Paint()
        ..color = accentColor.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
    );

    // Chessboard squares
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        final isLight = (row + col) % 2 == 0;
        final rect = Rect.fromLTWH(
          boardLeft + col * sq,
          boardTop + row * sq,
          sq,
          sq,
        );
        canvas.drawRect(
          rect,
          Paint()..color = isLight
              ? accentColor.withValues(alpha: 0.25)
              : accentColor.withValues(alpha: 0.08),
        );
      }
    }

    // Board border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(boardLeft, boardTop, boardSize, boardSize),
        const Radius.circular(8),
      ),
      Paint()
        ..color = accentColor.withValues(alpha: 0.6)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    // Pulsing chess piece (knight silhouette simplified)
    final piecePaint = Paint()..color = accentColor;
    canvas.save();
    canvas.translate(cx, cy - sq * 0.2);
    canvas.scale(pulse * 0.28, pulse * 0.28);
    final knightPath = Path()
      ..moveTo(-30, 40)
      ..lineTo(30, 40)
      ..lineTo(25, 20)
      ..lineTo(35, 0)
      ..lineTo(20, -10)
      ..lineTo(30, -30)
      ..lineTo(10, -40)
      ..lineTo(-5, -20)
      ..lineTo(-15, -40)
      ..lineTo(-40, -20)
      ..lineTo(-35, 10)
      ..lineTo(-25, 20)
      ..close();
    canvas.drawPath(knightPath, piecePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PlayPainter old) => old.pulse != pulse;
}

// ── Puzzle Illustration — lightbulb with piece ─────────────────────────────
class _PuzzleIllustration extends StatefulWidget {
  const _PuzzleIllustration({required this.accentColor});
  final Color accentColor;

  @override
  State<_PuzzleIllustration> createState() => _PuzzleIllustrationState();
}

class _PuzzleIllustrationState extends State<_PuzzleIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _PuzzlePainter(accentColor: widget.accentColor, t: _ctrl.value),
      ),
    );
  }
}

class _PuzzlePainter extends CustomPainter {
  _PuzzlePainter({required this.accentColor, required this.t});
  final Color accentColor;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Glowing rings
    for (int i = 3; i >= 1; i--) {
      final r = size.width * 0.18 * i + t * 8;
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = accentColor.withValues(alpha: 0.06 / i)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }

    // Puzzle piece icon (simplified)
    final paint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final s = size.width * 0.22;
    // 4 squares arranged as a T-shape
    final positions = [
      Offset(cx - s, cy - s),
      Offset(cx, cy - s),
      Offset(cx - s, cy),
      Offset(cx, cy),
    ];
    for (int i = 0; i < 4; i++) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(positions[i].dx, positions[i].dy, s * 0.9, s * 0.9),
        const Radius.circular(6),
      );
      canvas.drawRRect(rect, i == 0 ? paint : strokePaint);
    }

    // Lightbulb glow at top
    canvas.drawCircle(
      Offset(cx + s * 0.5, cy - s * 1.1),
      12 + t * 4,
      Paint()
        ..color = accentColor.withValues(alpha: 0.25 * (0.7 + t * 0.3))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(
      Offset(cx + s * 0.5, cy - s * 1.1),
      8,
      Paint()..color = accentColor.withValues(alpha: 0.8 + t * 0.2),
    );
  }

  @override
  bool shouldRepaint(_PuzzlePainter old) => old.t != t;
}

// ── Analysis Illustration — bar chart with evaluation ─────────────────────
class _AnalysisIllustration extends StatefulWidget {
  const _AnalysisIllustration({required this.accentColor});
  final Color accentColor;

  @override
  State<_AnalysisIllustration> createState() => _AnalysisIllustrationState();
}

class _AnalysisIllustrationState extends State<_AnalysisIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _AnalysisPainter(accentColor: widget.accentColor, t: _ctrl.value),
      ),
    );
  }
}

class _AnalysisPainter extends CustomPainter {
  _AnalysisPainter({required this.accentColor, required this.t});
  final Color accentColor;
  final double t;

  static const _bars = [0.4, 0.7, 0.55, 0.9, 0.65, 0.8, 0.45];

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Glow backdrop
    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.42,
      Paint()
        ..color = accentColor.withValues(alpha: 0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
    );

    final totalW = size.width * 0.78;
    final barW = totalW / (_bars.length * 1.6);
    final spacing = totalW / _bars.length;
    final baseY = cy + size.height * 0.2;
    final maxH = size.height * 0.5;

    for (int i = 0; i < _bars.length; i++) {
      final animated = _bars[i] * (0.7 + 0.3 * (t + i * 0.1) % 1.0);
      final barH = maxH * animated;
      final x = cx - totalW / 2 + i * spacing + spacing / 2 - barW / 2;

      // Bar
      final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, baseY - barH, barW, barH),
        const Radius.circular(4),
      );
      canvas.drawRRect(
        rr,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [accentColor, accentColor.withValues(alpha: 0.3)],
          ).createShader(Rect.fromLTWH(x, baseY - barH, barW, barH)),
      );
    }

    // Baseline
    canvas.drawLine(
      Offset(cx - totalW / 2, baseY + 2),
      Offset(cx + totalW / 2, baseY + 2),
      Paint()
        ..color = accentColor.withValues(alpha: 0.3)
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_AnalysisPainter old) => old.t != t;
}

// ── Learn Illustration — open book with sparkles ──────────────────────────
class _LearnIllustration extends StatefulWidget {
  const _LearnIllustration({required this.accentColor});
  final Color accentColor;

  @override
  State<_LearnIllustration> createState() => _LearnIllustrationState();
}

class _LearnIllustrationState extends State<_LearnIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))
      ..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _LearnPainter(accentColor: widget.accentColor, t: _ctrl.value),
      ),
    );
  }
}

class _LearnPainter extends CustomPainter {
  _LearnPainter({required this.accentColor, required this.t});
  final Color accentColor;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Glow
    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.4,
      Paint()
        ..color = accentColor.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
    );

    // Open book shape
    final bookW = size.width * 0.65;
    final bookH = size.height * 0.42;
    final bookLeft = cx - bookW / 2;
    final bookTop = cy - bookH / 2 + 10;
    final paint = Paint()
      ..color = accentColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Left page
    final leftPage = RRect.fromLTRBAndCorners(
      bookLeft, bookTop, cx - 2, bookTop + bookH,
      topLeft: const Radius.circular(6),
      bottomLeft: const Radius.circular(6),
    );
    canvas.drawRRect(leftPage, paint);
    canvas.drawRRect(leftPage, strokePaint);

    // Right page
    final rightPage = RRect.fromLTRBAndCorners(
      cx + 2, bookTop, bookLeft + bookW, bookTop + bookH,
      topRight: const Radius.circular(6),
      bottomRight: const Radius.circular(6),
    );
    canvas.drawRRect(rightPage, paint);
    canvas.drawRRect(rightPage, strokePaint);

    // Lines inside pages
    final linePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.35)
      ..strokeWidth = 1.5;
    for (int i = 1; i <= 3; i++) {
      final y = bookTop + bookH * (i / 4.5);
      canvas.drawLine(
        Offset(bookLeft + 12, y),
        Offset(cx - 12, y),
        linePaint,
      );
      canvas.drawLine(
        Offset(cx + 12, y),
        Offset(bookLeft + bookW - 12, y),
        linePaint,
      );
    }

    // Orbiting sparkle stars
    final starPositions = [
      Offset(cx + 55 * math.cos(t * 2 * math.pi), cy - 55 * math.sin(t * 2 * math.pi)),
      Offset(cx - 45 * math.cos(t * 2 * math.pi + 1.2), cy + 45 * math.sin(t * 2 * math.pi + 1.2)),
      Offset(cx + 35 * math.cos(t * 2 * math.pi + 2.4), cy - 35 * math.sin(t * 2 * math.pi + 2.4)),
    ];
    for (int i = 0; i < starPositions.length; i++) {
      final opacity = 0.5 + 0.5 * math.sin(t * 2 * math.pi + i);
      canvas.drawCircle(
        starPositions[i],
        3.0 - i * 0.5,
        Paint()..color = accentColor.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_LearnPainter old) => old.t != t;
}
