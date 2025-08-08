import 'inappwebview_inspector_interface.dart';
import 'inappwebview_inspector_impl.dart';

/// Factory for creating WebView inspector instances
class InAppWebViewInspectorFactory {
  static InAppWebViewInspectorInterface? _instance;
  static InAppWebViewInspectorConfig _config = InAppWebViewInspectorConfig.defaultConfig;
  
  /// Initialize the inspector with custom configuration
  static void initialize({InAppWebViewInspectorConfig? config}) {
    _config = config ?? InAppWebViewInspectorConfig.defaultConfig;
    _instance = null; // Reset instance to apply new config
  }
  
  /// Get the singleton inspector instance
  static InAppWebViewInspectorInterface getInstance() {
    _instance ??= InAppWebViewInspectorImpl(_config);
    final instance = _instance;
    if (instance != null) {
      return instance;
    }
    throw StateError('InAppWebViewInspector instance is null');
  }
  
  /// Create a new inspector instance (for testing or multiple instances)
  static InAppWebViewInspectorInterface createInstance({InAppWebViewInspectorConfig? config}) {
    return InAppWebViewInspectorImpl(config ?? _config);
  }
  
  /// Dispose the current instance
  static void dispose() {
    _instance?.dispose();
    _instance = null;
  }
  
  /// Check if instance exists
  static bool get hasInstance => _instance != null;
}

/// Service locator for WebView inspection
class InAppWebViewInspectorService {
  static InAppWebViewInspectorInterface? _inspector;
  
  /// Register an inspector instance
  static void register(InAppWebViewInspectorInterface inspector) {
    _inspector = inspector;
  }
  
  /// Get the registered inspector instance
  static InAppWebViewInspectorInterface get inspector {
    final inspector = _inspector;
    if (inspector == null) {
      throw StateError('InAppWebViewInspector not registered. Call InAppWebViewInspectorService.register() first.');
    }
    return inspector;
  }
  
  /// Check if inspector is registered
  static bool get isRegistered => _inspector != null;
  
  /// Unregister the inspector
  static void unregister() {
    _inspector?.dispose();
    _inspector = null;
  }
}

/// Extension methods for easier inspector access
extension InAppWebViewInspectorExtension on InAppWebViewInspectorInterface {
  /// Execute script with error handling
  Future<bool> tryExecuteScript(String script) async {
    try {
      await executeScript(script);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Get WebView by ID
  InAppWebViewInspectorInstance? getWebView(String id) {
    return webViews[id];
  }
  
  /// Get active WebView instance
  InAppWebViewInspectorInstance? get activeWebView {
    return webViews[activeWebViewId];
  }
  
  /// Check if WebView is registered
  bool hasWebView(String id) {
    return webViews.containsKey(id);
  }
  
  /// Get console logs for specific WebView
  List<InAppWebViewInspectorConsoleMessage> getConsoleLogsForWebView(String webViewId) {
    return consoleLogs.where((log) => log.webViewId == webViewId).toList();
  }
  
  /// Get recent console logs (last n messages)
  List<InAppWebViewInspectorConsoleMessage> getRecentConsoleLogs(int count) {
    return consoleLogs.take(count).toList();
  }
}