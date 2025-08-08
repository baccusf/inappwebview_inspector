import 'inappwebview_inspector_interface.dart';
import 'inappwebview_inspector_factory.dart';
import '../utils/inappwebview_inspector_localizations.dart';

/// Main WebView Inspector class - Convenience class for quick setup
class InAppWebViewInspector {
  /// Initialize WebView inspection with default configuration
  static void initialize({
    bool debugMode = false,
    int maxConsoleLogCount = 1000,
    bool enableAutoResultLogging = true,
    bool enableScriptHistory = true,
    int maxScriptHistoryCount = 15,
    InAppWebViewInspectorLocalizations localizations =
        InAppWebViewInspectorLocalizations.english,
    Function(String script, String webViewId)? onScriptExecuted,
    Function(InAppWebViewInspectorConsoleMessage log)? onConsoleLog,
    Function(String error, String webViewId)? onError,
  }) {
    final config = InAppWebViewInspectorConfig(
      debugMode: debugMode,
      maxConsoleLogCount: maxConsoleLogCount,
      enableAutoResultLogging: enableAutoResultLogging,
      enableUnicodeQuoteNormalization: true,
      enableBase64ScriptEncoding: true,
      enableScriptHistory: enableScriptHistory,
      maxScriptHistoryCount: maxScriptHistoryCount,
      localizations: localizations,
      onScriptExecuted: onScriptExecuted,
      onConsoleLog: onConsoleLog,
      onError: onError,
    );

    InAppWebViewInspectorFactory.initialize(config: config);
    InAppWebViewInspectorService.register(
        InAppWebViewInspectorFactory.getInstance());
  }

  /// Initialize with custom configuration
  static void initializeWithConfig(InAppWebViewInspectorConfig config) {
    InAppWebViewInspectorFactory.initialize(config: config);
    InAppWebViewInspectorService.register(
        InAppWebViewInspectorFactory.getInstance());
  }

  /// Initialize with development mode (shortcut for common use case)
  static void initializeDevelopment({
    int maxConsoleLogCount = 500,
    bool enableScriptHistory = true,
    int maxScriptHistoryCount = 15,
    InAppWebViewInspectorLocalizations localizations =
        InAppWebViewInspectorLocalizations.english,
    Function(String script, String webViewId)? onScriptExecuted,
    Function(InAppWebViewInspectorConsoleMessage log)? onConsoleLog,
    Function(String error, String webViewId)? onError,
  }) {
    initialize(
      debugMode: true,
      maxConsoleLogCount: maxConsoleLogCount,
      enableAutoResultLogging: true,
      enableScriptHistory: enableScriptHistory,
      maxScriptHistoryCount: maxScriptHistoryCount,
      localizations: localizations,
      onScriptExecuted: onScriptExecuted,
      onConsoleLog: onConsoleLog,
      onError: onError,
    );
  }

  /// Initialize with production mode (minimal logging)
  static void initializeProduction({
    int maxConsoleLogCount = 100,
    bool enableAutoResultLogging = false,
    bool enableScriptHistory = false,
    InAppWebViewInspectorLocalizations localizations =
        InAppWebViewInspectorLocalizations.english,
  }) {
    initialize(
      debugMode: false,
      maxConsoleLogCount: maxConsoleLogCount,
      enableAutoResultLogging: enableAutoResultLogging,
      enableScriptHistory: enableScriptHistory,
      localizations: localizations,
    );
  }

  /// Get the current inspector instance
  static InAppWebViewInspectorInterface get instance =>
      InAppWebViewInspectorService.inspector;

  /// Check if inspector is initialized
  static bool get isInitialized => InAppWebViewInspectorService.isRegistered;

  /// Auto-initialize if not already initialized (for lazy loading)
  static InAppWebViewInspectorInterface getOrInitialize(
      {bool debugMode = false}) {
    if (!isInitialized) {
      initialize(debugMode: debugMode);
    }
    return instance;
  }

  /// Dispose the inspector
  static void dispose() {
    InAppWebViewInspectorService.unregister();
    InAppWebViewInspectorFactory.dispose();
  }

  // Convenience methods that delegate to the instance

  /// Register a WebView for inspection
  static void registerWebView(String id, controller, String url) {
    instance.registerWebView(id, controller, url);
  }

  /// Unregister a WebView
  static void unregisterWebView(String id) {
    instance.unregisterWebView(id);
  }

  /// Add console log from WebView
  static void addConsoleLog(String webViewId, consoleMessage) {
    instance.addConsoleLog(webViewId, consoleMessage);
  }

  /// Set WebView visibility
  static void setWebViewVisibility(String id, bool isVisible) {
    instance.setWebViewVisibility(id, isVisible);
  }

  /// Update WebView URL
  static void updateWebViewUrl(String id, String url) {
    instance.updateWebViewUrl(id, url);
  }

  /// Show inspector
  static void show() {
    instance.showInspector();
  }

  /// Hide inspector
  static void hide() {
    instance.hideInspector();
  }

  /// Toggle inspector visibility
  static void toggle() {
    instance.toggleInspectorVisibility();
  }

  /// Enable inspector
  static void enable() {
    instance.enableInspector();
  }

  /// Disable inspector
  static void disable() {
    instance.disableInspector();
  }

  /// Check if inspector is visible
  static bool get isVisible =>
      isInitialized ? instance.isInspectorVisible : false;

  /// Check if inspector is enabled
  static bool get isEnabled =>
      isInitialized ? instance.isInspectorEnabled : false;
}
