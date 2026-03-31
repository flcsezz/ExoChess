import 'package:exochess_mobile/src/styles/styles.dart';
import 'package:exochess_mobile/src/utils/navigation.dart';
import 'package:exochess_mobile/src/widgets/platform.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';

class LichessBrowserScreen extends StatefulWidget {
  const LichessBrowserScreen({
    required this.url,
    required this.title,
    super.key,
  });

  final String url;
  final String title;

  static Route<dynamic> buildRoute(BuildContext context, {required String url, required String title}) {
    return buildScreenRoute(
      context,
      screen: LichessBrowserScreen(url: url, title: title),
    );
  }

  @override
  State<LichessBrowserScreen> createState() => _LichessBrowserScreenState();
}

class _LichessBrowserScreenState extends State<LichessBrowserScreen> {
  late final WebViewController _controller;
  int _loadingProgress = 0;
  bool _canGoBack = false;
  bool _canGoForward = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress;
            });
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            _updateNavigation();
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _updateNavigation() async {
    final canGoBack = await _controller.canGoBack();
    final canGoForward = await _controller.canGoForward();
    if (mounted) {
      setState(() {
        _canGoBack = canGoBack;
        _canGoForward = canGoForward;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(
          widget.title.toUpperCase(),
          style: const TextStyle(fontFamily: 'NDot', fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Symbols.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_loadingProgress < 100)
            LinearProgressIndicator(
              value: _loadingProgress / 100.0,
              backgroundColor: theme.colorScheme.surface,
              color: theme.colorScheme.primary,
              minHeight: 2,
            ),
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Symbols.arrow_back_ios_new),
              onPressed: _canGoBack ? () => _controller.goBack() : null,
            ),
            IconButton(
              icon: const Icon(Symbols.arrow_forward_ios),
              onPressed: _canGoForward ? () => _controller.goForward() : null,
            ),
            const SizedBox(width: 48), // Spacer
            IconButton(
              icon: const Icon(Symbols.open_in_new),
              onPressed: () {
                // Future: launchUrl(Uri.parse(widget.url), mode: LaunchMode.externalApplication);
              },
            ),
          ],
        ),
      ),
    );
  }
}
