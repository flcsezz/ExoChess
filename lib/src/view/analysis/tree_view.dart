import 'package:exochess_mobile/src/model/analysis/analysis_controller.dart';
import 'package:exochess_mobile/src/model/analysis/analysis_preferences.dart';
import 'package:exochess_mobile/src/model/analysis/analysis_preload_service.dart';
import 'package:exochess_mobile/src/view/game/game_result_dialog.dart';
import 'package:exochess_mobile/src/widgets/pgn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const kOpeningHeaderHeight = 32.0;

class AnalysisTreeView extends ConsumerWidget {
  const AnalysisTreeView(this.options);

  final AnalysisOptions options;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrlProvider = analysisControllerProvider(options);

    final analysisState = ref.watch(ctrlProvider).requireValue;
    final prefs = ref.watch(analysisPreferencesProvider);
    final preloadState = options.gameId != null
        ? ref.watch(analysisPreloadServiceProvider(options.gameId!))
        : null;
    // enable computer analysis takes effect here only if it's a lichess game
    final enableServerAnalysis = !options.isLichessGameAnalysis || prefs.enableServerAnalysis;

    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          if (preloadState?.status == PreloadStatus.error)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Analysis failed: ${preloadState?.error}')),
                  TextButton(
                    onPressed: () => ref
                        .read(analysisPreloadServiceProvider(options.gameId!).notifier)
                        .retry(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          DebouncedPgnTreeView(
            root: analysisState.root,
            currentPath: analysisState.currentPath,
            livePath: analysisState.pathToLiveMove,
            pgnRootComments: analysisState.pgnRootComments,
            notifier: ref.read(ctrlProvider.notifier),
            shouldShowComputerAnalysis: enableServerAnalysis,
            shouldShowComments: enableServerAnalysis && prefs.showPgnComments,
            shouldShowAnnotations: enableServerAnalysis && prefs.showAnnotations,
            premovePaths: analysisState.forecast?.lines,
            displayMode: prefs.inlineNotation
                ? PgnTreeDisplayMode.inlineNotation
                : PgnTreeDisplayMode.twoColumn,
          ),
          if (analysisState.archivedGame != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GameResult(game: analysisState.archivedGame!),
            ),
        ],
      ),
    );
  }
}
