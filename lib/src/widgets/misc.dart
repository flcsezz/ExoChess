import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:chessigma_mobile/src/utils/l10n_context.dart';
import 'package:url_launcher/url_launcher.dart';

class AppBarChessigmaTitle extends StatelessWidget {
  const AppBarChessigmaTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset('assets/images/home_logo.png', height: 24),
            ),
          ),
          const TextSpan(text: ' Chessigma'),
        ],
      ),
      maxLines: 1,
    );
  }
}

/// A widget that displays a title in the app bar with auto-sizing text.
class AppBarTitleText extends StatelessWidget {
  const AppBarTitleText(
    this.text, {
    super.key,
    this.minFontSize,
    this.maxFontSize,
    this.maxLines = 1,
  }) : assert(maxLines > 0 && maxLines <= 2);

  final String text;
  final int maxLines;
  final double? minFontSize;
  final double? maxFontSize;

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      maxLines: maxLines,
      style: maxLines > 1 ? const TextStyle(height: 1) : null,
      minFontSize: minFontSize ?? 15.0,
      maxFontSize:
          maxFontSize ??
          (maxLines > 1 ? 18 : AppBarTheme.of(context).titleTextStyle?.fontSize ?? 20.0),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class ChessigmaMessage extends StatefulWidget {
  const ChessigmaMessage({super.key, this.style, this.textAlign = TextAlign.start});

  final TextStyle? style;
  final TextAlign textAlign;

  @override
  State<ChessigmaMessage> createState() => _ChessigmaMessageState();
}

class _ChessigmaMessageState extends State<ChessigmaMessage> {
  late TapGestureRecognizer _recognizer;

  @override
  void initState() {
    super.initState();
    _recognizer = TapGestureRecognizer()..onTap = _handleTap;
  }

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  void _handleTap() {
    launchUrl(Uri.parse('https://chessigma.com/features'));
  }

  @override
  Widget build(BuildContext context) {
    final trans = context.l10n.xIsAFreeYLibreOpenSourceChessServer('Chessigma', context.l10n.really);
    final regexp = RegExp(r'''^([^(]*\()([^)]*)(\).*)$''');
    final match = regexp.firstMatch(trans);
    final List<TextSpan> spans = [];
    if (match != null) {
      for (var i = 1; i <= match.groupCount; i++) {
        spans.add(
          TextSpan(
            text: match[i],
            style: i == 2 ? TextStyle(color: ColorScheme.of(context).primary) : null,
            recognizer: i == 2 ? _recognizer : null,
          ),
        );
      }
    } else {
      spans.add(TextSpan(text: trans));
    }

    return MergeSemantics(
      child: Text.rich(
        TextSpan(style: widget.style, children: spans),
        textAlign: widget.textAlign,
      ),
    );
  }
}
