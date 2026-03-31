import 'package:exochess_mobile/src/model/external_history/external_history.dart';
import 'package:exochess_mobile/src/model/external_history/external_history_provider.dart';
import 'package:exochess_mobile/src/styles/styles.dart';
import 'package:exochess_mobile/src/utils/navigation.dart';
import 'package:exochess_mobile/src/view/external_history/external_game_history_tile.dart';
import 'package:exochess_mobile/src/widgets/cyberpunk/glass_card.dart';
import 'package:exochess_mobile/src/widgets/cyberpunk/neon_button.dart';
import 'package:exochess_mobile/src/widgets/feedback.dart';
import 'package:exochess_mobile/src/widgets/platform.dart';
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
      appBar: PlatformAppBar(
        title: Text(
          '${params.source.displayName}: ${params.username}'.toUpperCase(),
          style: const TextStyle(fontFamily: 'NDot', fontSize: 18),
        ),
      ),
      body: historyState.when(
        data: (games) {
          if (games.isEmpty) {
            return Center(
              child: Text(
                'NO GAMES FOUND',
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20.0),
            itemCount: games.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12.0),
            itemBuilder: (context, index) {
              return Card(
                elevation: 0,
                color: Theme.of(context).brightness == Brightness.dark ? null : Colors.white,
                child: ExternalGameHistoryTile(item: games[index]),
              );
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
    final isDark = theme.brightness == Brightness.dark;

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
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
                ),
                child: Icon(Icons.person_off, size: 64, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 32),
              Text(
                'USERNAME NOT FOUND'.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'NDot',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'NO PLAYER NAMED "${params.username.toUpperCase()}" WAS FOUND ON ${params.source.displayName.toUpperCase()}.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('GO BACK'),
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
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Icon(Icons.hourglass_empty, size: 64, color: Colors.orange),
              ),
              const SizedBox(height: 32),
              const Text(
                'RATE LIMITED',
                style: TextStyle(
                  fontFamily: 'NDot',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'TOO MANY REQUESTS. PLEASE WAIT A MOMENT AND TRY AGAIN.'.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: onRetry,
                child: const Text('RETRY'),
              ),
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
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
              ),
              child: Icon(Icons.error_outline, size: 64, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 32),
            const Text(
              'SOMETHING WENT WRONG',
              style: TextStyle(
                fontFamily: 'NDot',
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              error.toString().toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SpaceMono',
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(onPressed: onRetry, child: const Text('RETRY')),
          ],
        ),
      ),
    );
  }
}
