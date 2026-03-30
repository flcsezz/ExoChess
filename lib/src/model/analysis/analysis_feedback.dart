import 'package:chessigma_mobile/src/model/common/feedback_data.dart';
import 'package:flutter/material.dart';

enum AnalysisQuality { brilliant, great, best, excellent, good, inaccuracy, mistake, blunder }

enum AnalysisSeverity { info, warning, error }

class AnalysisFeedback implements FeedbackData {
  final AnalysisQuality quality;
  final AnalysisSeverity severity;
  final String _label;
  final String badgeKey;

  const AnalysisFeedback({
    required this.quality,
    required this.severity,
    required String label,
    required this.badgeKey,
  }) : _label = label;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalysisFeedback &&
        other.quality == quality &&
        other.severity == severity &&
        other._label == _label &&
        other.badgeKey == badgeKey;
  }

  @override
  int get hashCode => Object.hash(quality, severity, _label, badgeKey);

  @override
  String label(BuildContext context) => _label;

  String get staticLabel => _label;

  @override
  Color get color {
    switch (quality) {
      case AnalysisQuality.brilliant:
        return const Color(0xFF00F2FF); // Cyan Neon
      case AnalysisQuality.great:
        return const Color(0xFF00FF85); // Green Neon
      case AnalysisQuality.best:
      case AnalysisQuality.excellent:
      case AnalysisQuality.good:
        return const Color(0xFF9DFF00); // Lime Neon
      case AnalysisQuality.inaccuracy:
        return const Color(0xFFFFD600); // Yellow Neon
      case AnalysisQuality.mistake:
        return const Color(0xFFFF8A00); // Orange Neon
      case AnalysisQuality.blunder:
        return const Color(0xFFFF005C); // Pink/Red Neon
    }
  }

  @override
  IconData get icon {
    switch (quality) {
      case AnalysisQuality.brilliant:
        return Icons.auto_awesome;
      case AnalysisQuality.great:
        return Icons.stars;
      case AnalysisQuality.best:
        return Icons.verified;
      case AnalysisQuality.excellent:
        return Icons.thumb_up;
      case AnalysisQuality.good:
        return Icons.check_circle;
      case AnalysisQuality.inaccuracy:
        return Icons.help_outline;
      case AnalysisQuality.mistake:
        return Icons.warning_amber;
      case AnalysisQuality.blunder:
        return Icons.dangerous;
    }
  }

  @override
  String get symbol {
    switch (quality) {
      case AnalysisQuality.brilliant:
        return '!!';
      case AnalysisQuality.great:
        return '!';
      case AnalysisQuality.best:
        return '★';
      case AnalysisQuality.excellent:
        return '!!';
      case AnalysisQuality.good:
        return '!';
      case AnalysisQuality.inaccuracy:
        return '?!';
      case AnalysisQuality.mistake:
        return '?';
      case AnalysisQuality.blunder:
        return '??';
    }
  }

  factory AnalysisFeedback.fromShift(double shift, {bool isBestMove = false}) {
    if (isBestMove || shift <= 0) {
      return const AnalysisFeedback(
        quality: AnalysisQuality.best,
        severity: AnalysisSeverity.info,
        label: 'Best',
        badgeKey: 'best_move',
      );
    } else if (shift <= 0.02) {
      return const AnalysisFeedback(
        quality: AnalysisQuality.excellent,
        severity: AnalysisSeverity.info,
        label: 'Excellent',
        badgeKey: 'excellent_move',
      );
    } else if (shift <= 0.05) {
      return const AnalysisFeedback(
        quality: AnalysisQuality.good,
        severity: AnalysisSeverity.info,
        label: 'Good',
        badgeKey: 'good_move',
      );
    } else if (shift <= 0.11) {
      return const AnalysisFeedback(
        quality: AnalysisQuality.inaccuracy,
        severity: AnalysisSeverity.warning,
        label: 'Inaccuracy',
        badgeKey: 'inaccuracy',
      );
    } else if (shift <= 0.24) {
      return const AnalysisFeedback(
        quality: AnalysisQuality.mistake,
        severity: AnalysisSeverity.warning,
        label: 'Mistake',
        badgeKey: 'mistake',
      );
    } else {
      return const AnalysisFeedback(
        quality: AnalysisQuality.blunder,
        severity: AnalysisSeverity.error,
        label: 'Blunder',
        badgeKey: 'blunder',
      );
    }
  }

  factory AnalysisFeedback.fromCpLoss(int cpLoss) {
    if (cpLoss < 0) {
      return const AnalysisFeedback(
        quality: AnalysisQuality.great,
        severity: AnalysisSeverity.info,
        label: 'Great',
        badgeKey: 'great_move',
      );
    } else if (cpLoss <= 5) {
      return const AnalysisFeedback(
        quality: AnalysisQuality.best,
        severity: AnalysisSeverity.info,
        label: 'Best',
        badgeKey: 'best_move',
      );
    } else if (cpLoss <= 15) {
      return const AnalysisFeedback(
        quality: AnalysisQuality.excellent,
        severity: AnalysisSeverity.info,
        label: 'Excellent',
        badgeKey: 'excellent_move',
      );
    } else if (cpLoss <= 30) {
      return const AnalysisFeedback(
        quality: AnalysisQuality.good,
        severity: AnalysisSeverity.info,
        label: 'Good',
        badgeKey: 'good_move',
      );
    } else if (cpLoss <= 100) {
      return const AnalysisFeedback(
        quality: AnalysisQuality.inaccuracy,
        severity: AnalysisSeverity.warning,
        label: 'Inaccuracy',
        badgeKey: 'inaccuracy',
      );
    } else if (cpLoss <= 300) {
      return const AnalysisFeedback(
        quality: AnalysisQuality.mistake,
        severity: AnalysisSeverity.warning,
        label: 'Mistake',
        badgeKey: 'mistake',
      );
    } else {
      return const AnalysisFeedback(
        quality: AnalysisQuality.blunder,
        severity: AnalysisSeverity.error,
        label: 'Blunder',
        badgeKey: 'blunder',
      );
    }
  }
}
