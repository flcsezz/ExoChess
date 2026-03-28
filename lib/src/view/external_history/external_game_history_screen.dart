import 'package:chessigma_mobile/src/model/external_history/external_history.dart';
import 'package:chessigma_mobile/src/model/external_history/external_history_provider.dart';
import 'package:chessigma_mobile/src/styles/styles.dart';
import 'package:chessigma_mobile/src/utils/navigation.dart';
import 'package:chessigma_mobile/src/view/external_history/external_game_history_tile.dart';
import 'package:chessigma_mobile/src/widgets/cyberpunk/glass_card.dart';
import 'package:chessigma_mobile/src/widgets/cyberpunk/neon_button.dart';
import 'package:chessigma_mobile/src/widgets/feedback.dart';
import 'package:chessigma_mobile/src/widgets/platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExternalGameHistoryScreen extends ConsumerWidget {
  const ExternalGameHistoryScreen({required this.params, super.key});

  final ExternalUserHistoryParams params;

  static Route<dynamic> buildRoute(BuildContext context, ExternalUserHistoryParams params) {
    return buildScreenRoute(context, screen: ExternalGameHistoryScreen(params: params));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(externalUserHistoryProvider(params));

    return PlatformScaffold(
      appBar: PlatformAppBar(title: Text('${params.source.displayName}: ${params.username}')),
      body: historyState.when(
        data: (games) {
          if (games.isEmpty) {
            return const Center(child: Text('No games found'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(8.0),
            itemCount: games.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8.0),
            itemBuilder: (context, index) {
              return GlassCard(child: ExternalGameHistoryTile(item: games[index]));
            },
          );
        },
        error: (e, st) => _ErrorView(
          error: e,
          params: params,
          onRetry: () => ref.invalidate(externalUserHistoryProvider(params)),
        ),
        loading: () => const CenterLoadingIndicator(),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.params, required this.onRetry});

  final Object error;
  final ExternalUserHistoryParams params;
  final VoidCallback onRetry;

  bool get _isUserNotFound {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('user not found') ||
        errorStr.contains('404') ||
        errorStr.contains('not found');
  }

  bool get _isRateLimited {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('rate limit') ||
        errorStr.contains('429') ||
        errorStr.contains('too many requests');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isUserNotFound) {
      return Center(
        child: Padding(
          padding: Styles.bodySectionPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_off, size: 64, color: Colors.redAccent),
              ),
              const SizedBox(height: 24),
              Text(
                'Username Not Found',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'No player named "${params.username}" was found on ${params.source.displayName}.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 15),
              ),
              const SizedBox(height: 8),
              Text(
                'Please check the spelling and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
              ),
              const SizedBox(height: 32),
              NeonButton(
                onPressed: () => Navigator.of(context).pop(),
                label: 'Go Back',
                glowColor: Colors.redAccent,
              ),
            ],
          ),
        ),
      );
    }

    if (_isRateLimited) {
      return Center(
        child: Padding(
          padding: Styles.bodySectionPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hourglass_empty, size: 64, color: Colors.orangeAccent),
              ),
              const SizedBox(height: 24),
              Text(
                'Rate Limited',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Too many requests. Please wait a moment and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 15),
              ),
              const SizedBox(height: 32),
              NeonButton(onPressed: onRetry, label: 'Retry', glowColor: Colors.orangeAccent),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: Styles.bodySectionPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            ),
            const SizedBox(height: 24),
            Text(
              'Something Went Wrong',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
            ),
            const SizedBox(height: 32),
            NeonButton(onPressed: onRetry, label: 'Retry', glowColor: Colors.redAccent),
          ],
        ),
      ),
    );
  }
}
