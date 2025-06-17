import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FitbitAuthWebView extends StatefulWidget {
  final String authUrl;
  final Function(String) onCodeReceived;

  const FitbitAuthWebView({
    Key? key,
    required this.authUrl,
    required this.onCodeReceived,
  }) : super(key: key);

  @override
  State<FitbitAuthWebView> createState() => _FitbitAuthWebViewState();
}

class _FitbitAuthWebViewState extends State<FitbitAuthWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://localhost')) {
              final uri = Uri.parse(request.url);
              final code = uri.queryParameters['code'];
              if (code != null) {
                widget.onCodeReceived(code);
                Navigator.pop(context);
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fitbit 授權')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
