import 'dart:async';

import 'package:chessigma_mobile/src/model/common/id.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PreloadStatus { initial, loading, success, error }

class PreloadState {
  final PreloadStatus status;
  final String? error;

  const PreloadState({
    required this.status,
    this.error,
  });

  const PreloadState.initial()
      : status = PreloadStatus.initial,
        error = null;
  const PreloadState.loading()
      : status = PreloadStatus.loading,
        error = null;
  const PreloadState.success()
      : status = PreloadStatus.success,
        error = null;
  const PreloadState.error(this.error) : status = PreloadStatus.error;
}

final analysisPreloadServiceProvider =
    NotifierProvider.family<AnalysisPreloadNotifier, PreloadState, GameId>(
  AnalysisPreloadNotifier.new,
);

class AnalysisPreloadNotifier extends Notifier<PreloadState> {
  AnalysisPreloadNotifier(this.gameId);

  final GameId gameId;

  @override
  PreloadState build() {
    return const PreloadState.initial();
  }

  void preload() {
    if (state.status != PreloadStatus.initial) return;

    state = const PreloadState.loading();
    _runPreload();
  }

  Future<void> _runPreload() async {
    try {
      // Simulate warmup
      await Future<void>.delayed(const Duration(milliseconds: 500));
      state = const PreloadState.success();
    } catch (e) {
      state = PreloadState.error(e.toString());
    }
  }

  void retry() {
    state = const PreloadState.initial();
    preload();
  }
}
