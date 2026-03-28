enum AnalysisQuality { best, great, good, inaccuracy, mistake, blunder }

enum AnalysisSeverity { info, warning, error }

class AnalysisFeedback {
  final AnalysisQuality quality;
  final AnalysisSeverity severity;
  final String label;
  final String badgeKey;

  const AnalysisFeedback({
    required this.quality,
    required this.severity,
    required this.label,
    required this.badgeKey,
  });

  factory AnalysisFeedback.fromCpLoss(int cpLoss) {
    if (cpLoss <= 5) {
      return const AnalysisFeedback(
        quality: .best,
        severity: .info,
        label: 'Best',
        badgeKey: 'best_move',
      );
    } else if (cpLoss <= 20) {
      return const AnalysisFeedback(
        quality: .great,
        severity: .info,
        label: 'Great',
        badgeKey: 'great_move',
      );
    } else if (cpLoss <= 50) {
      return const AnalysisFeedback(
        quality: .good,
        severity: .info,
        label: 'Good',
        badgeKey: 'good_move',
      );
    } else if (cpLoss <= 100) {
      return const AnalysisFeedback(
        quality: .inaccuracy,
        severity: .warning,
        label: 'Inaccuracy',
        badgeKey: 'inaccuracy',
      );
    } else if (cpLoss <= 300) {
      return const AnalysisFeedback(
        quality: .mistake,
        severity: .warning,
        label: 'Mistake',
        badgeKey: 'mistake',
      );
    } else {
      return const AnalysisFeedback(
        quality: .blunder,
        severity: .error,
        label: 'Blunder',
        badgeKey: 'blunder',
      );
    }
  }
}
