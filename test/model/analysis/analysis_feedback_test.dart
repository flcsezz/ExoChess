import 'package:flutter_test/flutter_test.dart';
import 'package:chessigma_mobile/src/model/analysis/analysis_feedback.dart';

void main() {
  group('AnalysisFeedback', () {
    test('classifies move quality correctly based on centipawn loss', () {
      expect(AnalysisFeedback.fromCpLoss(0).quality, AnalysisQuality.best);
      expect(AnalysisFeedback.fromCpLoss(10).quality, AnalysisQuality.great);
      expect(AnalysisFeedback.fromCpLoss(30).quality, AnalysisQuality.good);
      expect(AnalysisFeedback.fromCpLoss(60).quality, AnalysisQuality.inaccuracy);
      expect(AnalysisFeedback.fromCpLoss(150).quality, AnalysisQuality.mistake);
      expect(AnalysisFeedback.fromCpLoss(350).quality, AnalysisQuality.blunder);
    });

    test('exposes correct display metadata for each quality', () {
      final best = AnalysisFeedback.fromCpLoss(0);
      expect(best.label, 'Best');
      expect(best.badgeKey, 'best_move');
      expect(best.severity, AnalysisSeverity.info);

      final blunder = AnalysisFeedback.fromCpLoss(350);
      expect(blunder.label, 'Blunder');
      expect(blunder.badgeKey, 'blunder');
      expect(blunder.severity, AnalysisSeverity.error);
    });
  });
}
