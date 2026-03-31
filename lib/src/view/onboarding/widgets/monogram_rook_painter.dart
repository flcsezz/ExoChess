import 'package:flutter/material.dart';
import 'package:exochess_mobile/src/view/onboarding/onboarding_screen.dart' show kObRed, kObWhite;

/// Custom painter that draws the ExoChess Monogram Rook (Σ inside a Rook)
class MonogramRookPainter extends CustomPainter {
  const MonogramRookPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final s = size.width * 0.35; // Matches the scale logic from previous painter

    // Glowing halo
    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.48,
      Paint()
        ..color = kObRed.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 32),
    );

    // Outer ring
    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.44,
      Paint()
        ..color = kObRed.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill,
    );

    canvas.save();
    canvas.translate(cx, cy);

    // We want the rook to fill a similar area (scale to fit approx width 0.7*s)
    // Map our 100x100 path center (50, 50) to (0, 0) and scale
    final targetSize = s * 1.5; 
    final scaleFactor = targetSize / 100.0;
    canvas.scale(scaleFactor, scaleFactor);
    canvas.translate(-50.0, -50.0);

    final rookPaint = Paint()
      ..color = kObRed
      ..style = PaintingStyle.fill;
    final outlinePaint = Paint()
      ..color = kObWhite
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // Body of the Rook
    final basePath = Path()
      ..moveTo(25, 18)
      ..lineTo(30, 35)
      ..lineTo(70, 35)
      ..lineTo(75, 18)
      ..lineTo(63, 18)
      ..lineTo(63, 26)
      ..lineTo(54, 26)
      ..lineTo(54, 18)
      ..lineTo(46, 18)
      ..lineTo(46, 26)
      ..lineTo(37, 26)
      ..lineTo(37, 18)
      ..close()
      // Base
      ..moveTo(15, 92)
      ..lineTo(85, 92)
      ..lineTo(80, 84)
      ..lineTo(20, 84)
      ..close();

    // Sigma Outline inside the Rook
    final sigmaPath = Path()
      ..moveTo(28, 40)
      ..lineTo(72, 40)
      ..lineTo(68, 50)
      ..lineTo(45, 50)
      ..lineTo(58, 63)
      ..lineTo(45, 76)
      ..lineTo(75, 76)
      ..lineTo(78, 86)
      ..lineTo(22, 86)
      ..lineTo(45, 63)
      ..close();

    canvas.drawPath(basePath, rookPaint);
    canvas.drawPath(basePath, outlinePaint);
    
    canvas.drawPath(sigmaPath, rookPaint);
    canvas.drawPath(sigmaPath, outlinePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
