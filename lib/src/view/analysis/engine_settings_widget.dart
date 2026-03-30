import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chessigma_mobile/src/model/engine/engine.dart';
import 'package:chessigma_mobile/src/model/engine/evaluation_preferences.dart';
import 'package:chessigma_mobile/src/utils/l10n_context.dart';
import 'package:chessigma_mobile/src/widgets/list.dart';
import 'package:chessigma_mobile/src/widgets/settings.dart';

class EngineSettingsWidget extends ConsumerWidget {
  const EngineSettingsWidget({
    this.onToggleLocalEvaluation,
    this.onToggleLichessCloudEval,
    required this.onSetEngineSearchTime,
    this.onSetNumEvalLines,
    required this.onSetEngineCores,
    super.key,
  });

  final VoidCallback? onToggleLocalEvaluation;
  final VoidCallback? onToggleLichessCloudEval;
  final void Function(Duration) onSetEngineSearchTime;
  final void Function(int)? onSetNumEvalLines;
  final void Function(int) onSetEngineCores;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(engineEvaluationPreferencesProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onToggleLocalEvaluation != null || onToggleLichessCloudEval != null)
          ListSection(
            children: [
              if (onToggleLocalEvaluation != null)
                SwitchSettingTile(
                  title: Text(context.l10n.toggleLocalEvaluation),
                  value: prefs.isEnabled,
                  onChanged: (_) {
                    onToggleLocalEvaluation!.call();
                  },
                ),
              if (onToggleLichessCloudEval != null)
                SwitchSettingTile(
                  title: const Text('Lichess cloud evaluation'),
                  value: prefs.enableLichessCloudEval,
                  onChanged: (_) {
                    onToggleLichessCloudEval!.call();
                  },
                ),
            ],
          ),
        ListSection(
          header: const SettingsSectionTitle('Stockfish'),
          children: [
            SliderSettingsTile(
              title: const Text('Search time'),
              value: prefs.engineSearchTime.inSeconds.toDouble(),
              values: kAvailableEngineSearchTimes.map((e) => e.inSeconds.toDouble()).toList(),
              labelBuilder: (value) =>
                  value == kMaxEngineSearchTime.inSeconds.toDouble() ? '∞' : '${value.toInt()}s',
              onChangeEnd: (value) {
                onSetEngineSearchTime(Duration(seconds: value.toInt()));
              },
            ),
            if (onSetNumEvalLines != null)
              SliderSettingsTile(
                title: Text(context.l10n.multipleLines),
                value: prefs.numEvalLines.toDouble(),
                values: const [0, 1, 2, 3],
                labelBuilder: (value) => value.toInt().toString(),
                onChangeEnd: (value) => onSetNumEvalLines!.call(value.toInt()),
              ),
            if (maxEngineCores > 1)
              SliderSettingsTile(
                title: Text(context.l10n.cpus),
                value: prefs.numEngineCores.toDouble(),
                values: List.generate(
                  maxEngineCores,
                  (index) => index + 1,
                ).map((e) => e.toDouble()).toList(),
                labelBuilder: (value) => value.toInt().toString(),
                onChangeEnd: (value) => onSetEngineCores(value.toInt()),
              ),
          ],
        ),
      ],
    );
  }
}
