import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chessigma_mobile/src/model/analysis/analysis_preload_service.dart';
import 'package:chessigma_mobile/src/model/common/id.dart';

void main() {
  group('AnalysisPreloadService', () {
    test('starts analysis on preload request', () {
      final container = ProviderContainer();
      final service = container.read(analysisPreloadServiceProvider);
      
      const gameId = GameId('testgame');
      service.preload(gameId);
      
      expect(service.isPreloading(gameId), isTrue);
    });

    test('reuses cache for same game', () {
      final container = ProviderContainer();
      final service = container.read(analysisPreloadServiceProvider);
      
      const gameId = GameId('testgame');
      service.preload(gameId);
      final firstFuture = service.getPreloadFuture(gameId);
      
      service.preload(gameId);
      final secondFuture = service.getPreloadFuture(gameId);
      
      expect(firstFuture, same(secondFuture));
    });
  });
}
