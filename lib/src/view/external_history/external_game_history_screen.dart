import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chessigma_mobile/src/model/external_history/external_history.dart';
import 'package:chessigma_mobile/src/model/external_history/external_history_provider.dart';
import 'package:chessigma_mobile/src/utils/navigation.dart';
import 'package:chessigma_mobile/src/view/external_history/external_game_history_tile.dart';
import 'package:chessigma_mobile/src/widgets/feedback.dart';
import 'package:chessigma_mobile/src/widgets/platform.dart';

class ExternalGameHistoryScreen extends ConsumerWidget {
  const ExternalGameHistoryScreen({
    required this.params,
    super.key,
  });

  final ExternalUserHistoryParams params;

  static Route<dynamic> buildRoute(
    BuildContext context,
    ExternalUserHistoryParams params,
  ) {
    return buildScreenRoute(
      context,
      screen: ExternalGameHistoryScreen(params: params),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(externalUserHistoryProvider(params));

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text('${params.source.displayName}: ${params.username}'),
      ),
      body: historyState.when(
        data: (games) {
          if (games.isEmpty) {
            return const Center(child: Text('No games found'));
          }
          return ListView.separated(
            itemCount: games.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return ExternalGameHistoryTile(item: games[index]);
            },
          );
        },
        error: (e, st) => Center(child: Text('Error: $e')),
        loading: () => const CenterLoadingIndicator(),
      ),
    );
  }
}
