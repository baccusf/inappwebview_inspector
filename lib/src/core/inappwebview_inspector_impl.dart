import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'inappwebview_inspector_interface.dart';
import '../utils/inappwebview_inspector_script_utils.dart';

/// Concrete implementation of WebView inspection
class InAppWebViewInspectorImpl implements InAppWebViewInspectorInterface {
  final InAppWebViewInspectorConfig _config;

  final Map<String, InAppWebViewInspectorInstance> _webViews = {};
  final List<InAppWebViewInspectorConsoleMessage> _consoleLogs = [];

  String _activeWebViewId = '';
  bool _isInspectorVisible = false;
  bool _isInspectorEnabled = false;

  // Stream controllers for reactive updates
  final StreamController<List<InAppWebViewInspectorConsoleMessage>>
      _consoleLogsController =
      StreamController<List<InAppWebViewInspectorConsoleMessage>>.broadcast();
  final StreamController<String> _activeWebViewController =
      StreamController<String>.broadcast();
  final StreamController<bool> _visibilityController =
      StreamController<bool>.broadcast();
  final StreamController<bool> _enabledController =
      StreamController<bool>.broadcast();
  final StreamController<Map<String, InAppWebViewInspectorInstance>>
      _webViewsController =
      StreamController<Map<String, InAppWebViewInspectorInstance>>.broadcast();

  InAppWebViewInspectorImpl(
      [this._config = InAppWebViewInspectorConfig.defaultConfig]);

  // Stream getters for reactive updates
  Stream<List<InAppWebViewInspectorConsoleMessage>> get consoleLogsStream =>
      _consoleLogsController.stream;
  Stream<String> get activeWebViewIdStream => _activeWebViewController.stream;
  Stream<bool> get isInspectorVisibleStream => _visibilityController.stream;
  Stream<bool> get isInspectorEnabledStream => _enabledController.stream;
  Stream<Map<String, InAppWebViewInspectorInstance>> get webViewsStream =>
      _webViewsController.stream;

  @override
  void registerWebView(
      String id, InAppWebViewController controller, String url) {
    _webViews[id] = InAppWebViewInspectorInstance(
      id: id,
      controller: controller,
      url: url,
      isVisible: true, // 자동으로 visible로 설정
    );

    if (_activeWebViewId.isEmpty) {
      _activeWebViewId = id;
      _activeWebViewController.add(_activeWebViewId);
    }

    // 자동으로 인스펙터 활성화
    if (!_isInspectorEnabled) {
      _isInspectorEnabled = true;
      _enabledController.add(_isInspectorEnabled);
    }

    _webViewsController.add(Map.unmodifiable(_webViews));

    if (_config.debugMode) {
      debugPrint('InAppWebViewInspector: Registered WebView $id');
    }
  }

  @override
  void unregisterWebView(String id) {
    _webViews.remove(id);

    if (_activeWebViewId == id) {
      _activeWebViewId = _webViews.keys.isNotEmpty ? _webViews.keys.first : '';
      _activeWebViewController.add(_activeWebViewId);
    }

    _webViewsController.add(Map.unmodifiable(_webViews));

    if (_config.debugMode) {
      debugPrint('InAppWebViewInspector: Unregistered WebView $id');
    }
  }

  @override
  void setActiveWebView(String id) {
    if (_webViews.containsKey(id)) {
      _webViews.forEach((key, value) {
        value.isVisible = key == id;
      });
      _activeWebViewId = id;
      _activeWebViewController.add(_activeWebViewId);
      _webViewsController.add(Map.unmodifiable(_webViews));
    }
  }

  @override
  void setWebViewVisibility(String id, bool isVisible) {
    final webView = _webViews[id];
    if (webView != null) {
      webView.isVisible = isVisible;

      if (isVisible && _activeWebViewId != id) {
        setActiveWebView(id);
      }

      _webViewsController.add(Map.unmodifiable(_webViews));
    }
  }

  @override
  void updateWebViewUrl(String id, String url) {
    final webView = _webViews[id];
    if (webView != null) {
      webView.url = url;
      _webViewsController.add(Map.unmodifiable(_webViews));
    }
  }

  @override
  void addConsoleLog(String webViewId, ConsoleMessage message) {
    final consoleLog = InAppWebViewInspectorConsoleMessage(
      webViewId: webViewId,
      level: message.messageLevel,
      message: message.message,
      source: null, // sourceId not available in current version
      line: null, // lineNumber not available in current version
      timestamp: DateTime.now(),
    );

    _addConsoleLogInternal(consoleLog);

    // Call custom callback if provided
    _config.onConsoleLog?.call(consoleLog);
  }

  @override
  void addCustomConsoleLog(InAppWebViewInspectorConsoleMessage message) {
    _addConsoleLogInternal(message);

    // Call custom callback if provided
    _config.onConsoleLog?.call(message);
  }

  void _addConsoleLogInternal(InAppWebViewInspectorConsoleMessage consoleLog) {
    _consoleLogs.insert(0, consoleLog);

    if (_consoleLogs.length > _config.maxConsoleLogCount) {
      _consoleLogs.removeRange(_config.maxConsoleLogCount, _consoleLogs.length);
    }

    _consoleLogsController.add(List.unmodifiable(_consoleLogs));
  }

  @override
  void clearConsoleLogs() {
    _consoleLogs.clear();
    _consoleLogsController.add(List.unmodifiable(_consoleLogs));
  }

  @override
  Future<void> executeScript(String script) async {
    final activeWebView = _webViews[_activeWebViewId];
    if (activeWebView == null) {
      return;
    }

    try {
      String normalizedScript = script;

      if (_config.enableUnicodeQuoteNormalization) {
        // Convert unicode quotes to regular quotes
        normalizedScript = script
            .replaceAll('"', '"') // left double quotation mark
            .replaceAll('"', '"') // right double quotation mark
            .replaceAll(''', "'")  // left single quotation mark
            .replaceAll(''', "'"); // right single quotation mark
      }

      // Use enhanced script wrapping for better DOM object handling
      String wrappedScript;

      if (_config.enableBase64ScriptEncoding) {
        // Use safe serialization wrapping, then encode as Base64
        final safeScript =
            InAppWebViewInspectorScriptUtils.wrapScriptForSafeSerialization(
                normalizedScript);
        final scriptBytes = utf8.encode(safeScript);
        final base64Script = base64Encode(scriptBytes);

        wrappedScript = '''
          (function() {
            try {
              const decodedScript = atob("$base64Script");
              const result = eval(decodedScript);
              return result;
            } catch (e) {
              console.error('Script error:', e.message);
              throw e;
            }
          })();
        ''';
      } else {
        // Use safe serialization wrapping directly
        wrappedScript =
            InAppWebViewInspectorScriptUtils.wrapScriptForSafeSerialization(
                normalizedScript);
      }

      // Execute the script and capture the result
      final result = await activeWebView.controller
          .evaluateJavascript(source: wrappedScript);

      // Enhanced result handling
      if (result != null) {
        String resultString;
        try {
          if (result is Map) {
            // Handle structured results from safe serialization
            if (result.containsKey('type')) {
              switch (result['type']) {
                case 'DOM_ELEMENT':
                  resultString =
                      'DOM Element: <${result['tagName']}>${result['id'].isNotEmpty ? ' id="${result['id']}"' : ''}${result['className'].isNotEmpty ? ' class="${result['className']}"' : ''} textContent: "${result['textContent']}"';
                  break;
                case 'NODE_COLLECTION':
                  final items = result['items'] as List? ?? [];
                  final itemStrings = items.map((item) {
                    final tag = item['tagName'] ?? 'unknown';
                    final id = item['id'] ?? '';
                    final className = item['className'] ?? '';
                    final textContent = item['textContent'] ?? '';

                    String desc = '<$tag';
                    if (id.isNotEmpty) desc += ' id="$id"';
                    if (className.isNotEmpty) desc += ' class="$className"';
                    desc += '>';
                    if (textContent.isNotEmpty) desc += ' "$textContent"';

                    return desc;
                  }).toList();

                  resultString =
                      'NodeList (${result['length']} items): ${itemStrings.join(', ')}';
                  break;
                case 'FUNCTION':
                  resultString =
                      'Function: ${result['name']}() { ${result['source']} }';
                  break;
                case 'EXECUTION_ERROR':
                  resultString = 'Error: ${result['error']}';
                  break;
                default:
                  resultString = jsonEncode(result);
              }
            } else {
              resultString = jsonEncode(result);
            }
          } else if (result is List) {
            // Handle array results (e.g., from querySelectorAll)
            if (result.isNotEmpty &&
                result.first is Map &&
                result.first.containsKey('tagName')) {
              final elementStrings = result.map((item) {
                final tag = item['tagName'] ?? 'unknown';
                final id = item['id'] ?? '';
                final className = item['className'] ?? '';
                final textContent = item['textContent'] ?? '';

                String desc = '<$tag';
                if (id.isNotEmpty) desc += ' id="$id"';
                if (className.isNotEmpty) desc += ' class="$className"';
                desc += '>';
                if (textContent.isNotEmpty) desc += ' "$textContent"';

                return desc;
              }).toList();

              resultString =
                  'Elements (${result.length}): ${elementStrings.join(', ')}';
            } else {
              resultString = jsonEncode(result);
            }
          } else if (result is String) {
            resultString = result;
          } else {
            resultString = result.toString();
          }
        } catch (e) {
          resultString = '[Cannot convert result to string: $e]';
        }

        // Add result message to console output with ">>" prefix
        addCustomConsoleLog(InAppWebViewInspectorConsoleMessage(
          webViewId: _activeWebViewId,
          level: ConsoleMessageLevel.LOG,
          message: '>> $resultString',
          source: null,
          line: null,
          timestamp: DateTime.now(),
        ));
      } else {
        // Show when result is explicitly null
        addCustomConsoleLog(InAppWebViewInspectorConsoleMessage(
          webViewId: _activeWebViewId,
          level: ConsoleMessageLevel.LOG,
          message: '>> null',
          source: null,
          line: null,
          timestamp: DateTime.now(),
        ));
      }

      // Call custom callback if provided
      _config.onScriptExecuted?.call(script, _activeWebViewId);
    } catch (e) {
      // Enhanced error handling with suggestions
      final enhancedError =
          InAppWebViewInspectorScriptUtils.createEnhancedErrorMessage(
              e.toString(), script);
      addCustomConsoleLog(InAppWebViewInspectorConsoleMessage(
        webViewId: _activeWebViewId,
        level: ConsoleMessageLevel.ERROR,
        message: enhancedError,
        source: 'InAppWebViewInspector',
        line: 0,
        timestamp: DateTime.now(),
      ));

      // Call custom error callback if provided
      _config.onError?.call(enhancedError, _activeWebViewId);
    }
  }

  @override
  List<InAppWebViewInspectorConsoleMessage> get consoleLogs =>
      List.unmodifiable(_consoleLogs);

  @override
  String get activeWebViewId => _activeWebViewId;

  @override
  Map<String, InAppWebViewInspectorInstance> get webViews =>
      Map.unmodifiable(_webViews);

  @override
  bool get isInspectorVisible => _isInspectorVisible;

  @override
  bool get isInspectorEnabled => _isInspectorEnabled;

  @override
  void toggleInspectorVisibility() {
    _isInspectorVisible = !_isInspectorVisible;
    _visibilityController.add(_isInspectorVisible);
  }

  @override
  void showInspector() {
    _isInspectorVisible = true;
    _visibilityController.add(_isInspectorVisible);
  }

  @override
  void hideInspector() {
    _isInspectorVisible = false;
    _visibilityController.add(_isInspectorVisible);
  }

  @override
  void enableInspector() {
    _isInspectorEnabled = true;
    _enabledController.add(_isInspectorEnabled);
  }

  @override
  void disableInspector() {
    _isInspectorEnabled = false;
    _isInspectorVisible = false;
    _enabledController.add(_isInspectorEnabled);
    _visibilityController.add(_isInspectorVisible);
  }

  @override
  void toggleInspectorEnabled() {
    _isInspectorEnabled = !_isInspectorEnabled;
    if (!_isInspectorEnabled) {
      _isInspectorVisible = false;
      _visibilityController.add(_isInspectorVisible);
    }
    _enabledController.add(_isInspectorEnabled);
  }

  @override
  void dispose() {
    _consoleLogsController.close();
    _activeWebViewController.close();
    _visibilityController.close();
    _enabledController.close();
    _webViewsController.close();
  }
}
