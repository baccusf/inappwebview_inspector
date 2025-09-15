import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:inappwebview_inspector/inappwebview_inspector.dart';

void main() {
  // Simple initialization - show() will always auto-inject UI
  if (kDebugMode) {
    InAppWebViewInspector.initializeDevelopment(
      enableScriptHistory: true,
      maxScriptHistoryCount: 25, // Allow more scripts in history
      localizations: InAppWebViewInspectorLocalizations
          .english, // Change this to test other languages
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebView Inspector Demo - Zero Setup Auto UI Injection',
      // Optional: Add navigatorKey for optimal performance
      navigatorKey: InAppWebViewInspector.navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WebViewExample(),
    );
  }
}

class WebViewExample extends StatefulWidget {
  const WebViewExample({super.key});

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  InAppWebViewController? _webViewController;
  String _currentUrl = 'https://flutter.dev';

  // WebView identifier used throughout the class
  final String _webViewId = 'primary_webview';

  final List<String> _testUrls = [
    'https://flutter.dev',
    'https://pub.dev',
    'https://github.com',
    'https://stackoverflow.com',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('WebView Inspector Demo'),
            Text(
              'Simple Auto UI Injection Demo',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: InAppWebViewInspector.toggle,
            tooltip: 'Toggle Inspector\n(Zero Setup - UI Auto-Injected!)',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
            tooltip: 'About This Demo',
          ),
        ],
      ),
      body: Column(
        children: [
          // URL selector
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text('URL: '),
                Expanded(
                  child: DropdownButton<String>(
                    value: _currentUrl,
                    isExpanded: true,
                    items: _testUrls.map((url) {
                      return DropdownMenuItem(
                        value: url,
                        child: Text(url),
                      );
                    }).toList(),
                    onChanged: (String? newUrl) {
                      if (newUrl != null) {
                        setState(() {
                          _currentUrl = newUrl;
                        });
                        _webViewController?.loadUrl(
                          urlRequest: URLRequest(url: WebUri(newUrl)),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // WebView - Inspector UI will be auto-injected when show() is called
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(_currentUrl)),
              onWebViewCreated: (controller) {
                _webViewController = controller;

                // Register this WebView with the inspector using a descriptive identifier
                // This automatically enables the inspector and makes the WebView visible
                InAppWebViewInspector.registerWebView(
                    _webViewId, controller, _currentUrl);
              },
              onLoadStop: (controller, url) {
                if (url != null) {
                  final urlString = url.toString();

                  // Update URL in inspector
                  InAppWebViewInspector.updateWebViewUrl(
                      _webViewId, urlString);

                  // Only update _currentUrl if it's in our predefined list
                  // to avoid DropdownButton assertion errors
                  final matchingUrl = _testUrls.firstWhere(
                    (testUrl) => urlString.startsWith(testUrl),
                    orElse: () => _currentUrl, // Keep current if no match
                  );

                  if (matchingUrl != _currentUrl) {
                    setState(() {
                      _currentUrl = matchingUrl;
                    });
                  }
                }
              },
              onConsoleMessage: (controller, consoleMessage) {
                // Forward console messages to inspector
                InAppWebViewInspector.addConsoleLog(
                    _webViewId, consoleMessage);
              },
              initialSettings: InAppWebViewSettings(
                isInspectable: true,
                javaScriptEnabled: true,
                domStorageEnabled: true,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _executeTestScript,
            tooltip:
                'Execute Random Test Script\n(Try multiple times to see script history!)',
            heroTag: 'execute',
            child: const Icon(Icons.play_arrow),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.small(
            onPressed: _addTestLogs,
            tooltip: 'Add Test Console Logs',
            heroTag: 'logs',
            child: const Icon(Icons.message),
          ),
        ],
      ),
    );
  }

  void _executeTestScript() {
    // Create a variety of test scripts to demonstrate the memory-based script history
    // and new enhanced error handling
    final testScripts = [
      '''
        // Test script 1: Basic console logging
        console.log("🚀 WebView Inspector Demo");
        console.warn("⚠️ Warning: This is a test");
        console.error("❌ Error: This is also a test");
        "Basic logging test completed";
      ''',
      '''
        // Test script 2: DOM manipulation
        const title = document.title;
        console.log("📄 Current page title:", title);
        document.body.style.backgroundColor = "lightblue";
        "DOM manipulation completed";
      ''',
      '''
        // Test script 3: Browser information
        const info = {
          userAgent: navigator.userAgent,
          viewport: window.innerWidth + "x" + window.innerHeight,
          url: window.location.href,
          cookies: document.cookie || "No cookies"
        };
        console.log("🌐 Browser info:", info);
        JSON.stringify(info, null, 2);
      ''',
      '''
        // Test script 4: Performance testing
        const start = performance.now();
        for(let i = 0; i < 10000; i++) { /* Simple loop */ }
        const end = performance.now();
        const duration = end - start;
        console.log("⏱️ Performance test:", duration + "ms");
        "Performance test: " + duration.toFixed(2) + "ms";
      ''',
      '''
        // Test script 5: Local storage
        localStorage.setItem("inspector-test", "Hello from Inspector!");
        const stored = localStorage.getItem("inspector-test");
        console.log("💾 Local storage test:", stored);
        stored || "Local storage not available";
      ''',
      // NEW: Test scripts to demonstrate improved error handling
      '''
        // Test script 6: DOM element selection (improved handling)
        document.querySelector("h1");
      ''',
      '''
        // Test script 7: NodeList handling (improved handling)
        document.querySelectorAll("p");
      ''',
      '''
        // Test script 8: Class list handling (improved handling)
        document.body.classList;
      ''',
      '''
        // Test script 9: Style object handling (improved handling)
        document.body.style;
      ''',
      '''
        // Test script 10: Function handling (improved handling)
        document.querySelector;
      '''
    ];

    // Execute a random test script
    final randomIndex = DateTime.now().millisecond % testScripts.length;
    InAppWebViewInspector.instance.executeScript(testScripts[randomIndex]);
  }

  void _addTestLogs() {
    // Add some test console messages
    final testMessages = [
      InAppWebViewInspectorConsoleMessage(
        webViewId: _webViewId,
        level: ConsoleMessageLevel.LOG,
        message: 'Test log message from Flutter',
        source: 'Flutter',
        line: 1,
        timestamp: DateTime.now(),
      ),
      InAppWebViewInspectorConsoleMessage(
        webViewId: _webViewId,
        level: ConsoleMessageLevel.WARNING,
        message: 'Test warning message from Flutter',
        source: 'Flutter',
        line: 2,
        timestamp: DateTime.now().subtract(const Duration(seconds: 1)),
      ),
      InAppWebViewInspectorConsoleMessage(
        webViewId: _webViewId,
        level: ConsoleMessageLevel.ERROR,
        message: 'Test error message from Flutter',
        source: 'Flutter',
        line: 3,
        timestamp: DateTime.now().subtract(const Duration(seconds: 2)),
      ),
    ];

    for (final message in testMessages) {
      InAppWebViewInspector.instance.addCustomConsoleLog(message);
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔍 WebView Inspector Demo'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🎉 Zero Setup Auto UI Injection:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('• show() always auto-injects UI - no configuration needed'),
              Text('• Zero setup required - just call toggle()'),
              Text('• Automatic context discovery via WidgetsBinding'),
              Text('• Works in debug mode when inspector is initialized'),
              Text('• No manual Widget placement in your UI code'),
              Text('• Optional NavigatorKey for optimal performance'),
              SizedBox(height: 16),
              Text(
                '🚀 How to Use:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('1. Initialize inspector in main()'),
              Text('2. Tap the bug icon - UI auto-appears!'),
              Text('3. No manual Widget placement needed'),
              Text('4. Inspector automatically injects overlay UI'),
              Text('5. Try the pre-loaded scripts in history'),
              SizedBox(height: 16),
              Text(
                '⚙️ Implementation Details:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('• Simplified API - show() always attempts injection'),
              Text('• Auto Context Discovery via WidgetsBinding'),
              Text('• NavigatorKey fallback for optimal performance'),
              Text('• OverlayEntry-based UI injection system'),
              Text('• User controls initialization in debug mode'),
              Text('• Smart retry mechanism with developer guidance'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Unregister the WebView
    InAppWebViewInspector.unregisterWebView(_webViewId);
    super.dispose();
  }
}
