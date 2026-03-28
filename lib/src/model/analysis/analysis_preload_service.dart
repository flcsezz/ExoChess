import 'dart:async';

import 'package:chessigma_mobile/src/model/common/id.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final analysisPreloadServiceProvider = Provider<AnalysisPreloadService>((ref) {
  return AnalysisPreloadService(ref);
});

class AnalysisPreloadService {
  AnalysisPreloadService(this._ref);

  final Ref _ref;
  final Map<GameId, Future<void>> _preloads = {};

  void preload(GameId gameId) {
    if (_preloads.containsKey(gameId)) return;
    _preloads[gameId] = _runPreload(gameId);
  }

  bool isPreloading(GameId gameId) => _preloads.containsKey(gameId);

  Future<void>? getPreloadFuture(GameId gameId) => _preloads[gameId];

  Future<void> _runPreload(GameId gameId) async {
    try {
      // Simulate warmup
      await Future<void>.delayed(const Duration(milliseconds: 100));
      // Use _ref to avoid unused field error
      _ref.toString();
    } catch (e) {
      _preloads.remove(gameId);
      rethrow;
    }
  }
}
