import 'package:flutter/material.dart';
import 'package:chessigma_mobile/src/model/common/feedback_data.dart';

enum AnalysisQuality { best, great, good, inaccuracy, mistake, blunder }

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
  String label(BuildContext context) => _label;

  String get staticLabel => _label;

  @override
  Color get color {
    switch (quality) {
      case AnalysisQuality.best:
      case AnalysisQuality.great:
      case AnalysisQuality.good:
        return const Color(0xFF95B83C);
      case AnalysisQuality.inaccuracy:
        return const Color(0xFFF0C15C);
      case AnalysisQuality.mistake:
        return const Color(0xFFE6912C);
      case AnalysisQuality.blunder:
        return const Color(0xFFB33430);
    }
  }

  String get symbol {
    switch (quality) {
      case AnalysisQuality.best:
        return '★';
      case AnalysisQuality.great:
        return '!';
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

  factory AnalysisFeedback.fromCpLoss(int cpLoss) {
    if (cpLoss <= 5) {
      return const AnalysisFeedback(
        quality: AnalysisQuality.best,
        severity: AnalysisSeverity.info,
        label: 'Best',
        badgeKey: 'best_move',
      );
    } else if (cpLoss <= 20) {
      return const AnalysisFeedback(
        quality: AnalysisQuality.great,
        severity: AnalysisSeverity.info,
        label: 'Great',
        badgeKey: 'great_move',
      );
    } else if (cpLoss <= 50) {
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
