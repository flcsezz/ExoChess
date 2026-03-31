import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exochess_mobile/src/model/analysis/analysis_preload_service.dart';
import 'package:exochess_mobile/src/model/common/id.dart';

void main() {
  group('AnalysisPreloadService', () {
    test('starts analysis on preload request', () async {
      final container = ProviderContainer();
      const gameId = GameId('testgame');
      final notifier = container.read(analysisPreloadServiceProvider(gameId).notifier);
      
      notifier.preload();
      
      expect(container.read(analysisPreloadServiceProvider(gameId)).status, PreloadStatus.loading);
      
      await Future<void>.delayed(const Duration(milliseconds: 600));
      
      expect(container.read(analysisPreloadServiceProvider(gameId)).status, PreloadStatus.success);
    });

    test('retry resets state', () async {
      final container = ProviderContainer();
      const gameId = GameId('testgame');
      final notifier = container.read(analysisPreloadServiceProvider(gameId).notifier);
      
      notifier.preload();
      await Future<void>.delayed(const Duration(milliseconds: 600));
      expect(container.read(analysisPreloadServiceProvider(gameId)).status, PreloadStatus.success);
      
      notifier.retry();
      expect(container.read(analysisPreloadServiceProvider(gameId)).status, PreloadStatus.loading);
    });
  });
}
