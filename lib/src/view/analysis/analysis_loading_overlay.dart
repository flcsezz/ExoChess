import 'package:chessigma_mobile/src/model/analysis/analysis_preload_service.dart';
import 'package:flutter/material.dart';

class AnalysisLoadingOverlay extends StatelessWidget {
  const AnalysisLoadingOverlay({
    required this.state,
    required this.onRetry,
    super.key,
  });

  final PreloadState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.status == PreloadStatus.success || state.status == PreloadStatus.initial) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: state.status == PreloadStatus.error 
            ? colorScheme.errorContainer 
            : colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: state.status == PreloadStatus.error
                ? colorScheme.error.withValues(alpha: 0.5)
                : colorScheme.outlineVariant,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          if (state.status == PreloadStatus.loading) ...[
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Warming up engine...',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant, 
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ] else if (state.status == PreloadStatus.error) ...[
            Icon(Icons.error_outline, size: 16, color: colorScheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Engine warmup failed',
                style: TextStyle(
                  color: colorScheme.onErrorContainer, 
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onErrorContainer,
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: colorScheme.error.withValues(alpha: 0.1),
              ),
              child: const Text('Retry', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }
}
