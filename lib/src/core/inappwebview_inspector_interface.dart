import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../utils/inappwebview_inspector_localizations.dart';

/// Abstract interface for WebView inspection
abstract class InAppWebViewInspectorInterface {
  /// Register a WebView instance for inspection
  /// [id] - Unique identifier for this WebView (e.g., 'main', 'secondary', 'popup')
  /// 
  /// This automatically:
  /// - Enables the inspector if not already enabled
  /// - Makes the WebView visible in the inspector
  /// - Sets this WebView as active if it's the first one registered
  void registerWebView(String id, InAppWebViewController controller, String url);
  
  /// Unregister a WebView instance
  void unregisterWebView(String id);
  
  /// Set active WebView for inspection
  void setActiveWebView(String id);
  
  /// Set WebView visibility state
  void setWebViewVisibility(String id, bool isVisible);
  
  /// Update WebView URL (for URL changes during navigation)
  void updateWebViewUrl(String id, String url);
  
  /// Add console log message
  void addConsoleLog(String webViewId, ConsoleMessage message);
  
  /// Add custom console log message
  void addCustomConsoleLog(InAppWebViewInspectorConsoleMessage message);
  
  /// Execute JavaScript in active WebView
  Future<void> executeScript(String script);
  
  /// Clear all console logs
  void clearConsoleLogs();
  
  /// Get current console logs
  List<InAppWebViewInspectorConsoleMessage> get consoleLogs;
  
  /// Get active WebView ID
  String get activeWebViewId;
  
  /// Get all registered WebViews
  Map<String, InAppWebViewInspectorInstance> get webViews;
  
  /// Inspector visibility state
  bool get isInspectorVisible;
  
  /// Inspector enabled state (for toggle in settings)
  bool get isInspectorEnabled;
  
  /// Toggle inspector visibility
  void toggleInspectorVisibility();
  
  /// Show inspector
  void showInspector();
  
  /// Hide inspector
  void hideInspector();
  
  /// Enable inspector (shows button)
  void enableInspector();
  
  /// Disable inspector (hides button and inspector view)
  void disableInspector();
  
  /// Toggle inspector enabled state
  void toggleInspectorEnabled();
  
  /// Dispose resources
  void dispose();
}

/// WebView inspection configuration
class InAppWebViewInspectorConfig {
  /// Maximum number of console logs to keep
  final int maxConsoleLogCount;
  
  /// Enable automatic result logging for script execution
  final bool enableAutoResultLogging;
  
  /// Enable unicode quote normalization
  final bool enableUnicodeQuoteNormalization;
  
  /// Enable Base64 encoding for script execution
  final bool enableBase64ScriptEncoding;
  
  /// Debug mode enabled
  final bool debugMode;
  
  /// Enable script history feature
  final bool enableScriptHistory;
  
  /// Maximum number of script history items
  final int maxScriptHistoryCount;
  
  /// Custom script execution callback
  final Function(String script, String webViewId)? onScriptExecuted;
  
  /// Custom console log callback
  final Function(InAppWebViewInspectorConsoleMessage log)? onConsoleLog;
  
  /// Custom error callback
  final Function(String error, String webViewId)? onError;
  
  /// Localization settings for UI text
  final InAppWebViewInspectorLocalizations localizations;
  
  const InAppWebViewInspectorConfig({
    this.maxConsoleLogCount = 1000,
    this.enableAutoResultLogging = true,
    this.enableUnicodeQuoteNormalization = true,
    this.enableBase64ScriptEncoding = true,
    this.debugMode = false,
    this.enableScriptHistory = true,
    this.maxScriptHistoryCount = 15,
    this.onScriptExecuted,
    this.onConsoleLog,
    this.onError,
    this.localizations = InAppWebViewInspectorLocalizations.english,
  });
  
  static const InAppWebViewInspectorConfig defaultConfig = InAppWebViewInspectorConfig();
}

/// WebView instance information
class InAppWebViewInspectorInstance {
  final String id;
  final InAppWebViewController controller;
  String url;
  bool isVisible;
  
  InAppWebViewInspectorInstance({
    required this.id,
    required this.controller,
    required this.url,
    this.isVisible = false,
  });
}

/// Console message for inspection
class InAppWebViewInspectorConsoleMessage {
  final String webViewId;
  final ConsoleMessageLevel level;
  final String message;
  final String? source;
  final int? line;
  final DateTime timestamp;
  
  InAppWebViewInspectorConsoleMessage({
    required this.webViewId,
    required this.level,
    required this.message,
    this.source,
    this.line,
    required this.timestamp,
  });
  
  /// Get color for message level
  Color get levelColor {
    switch (level) {
      case ConsoleMessageLevel.ERROR:
        return const Color(0xFFFF5252);
      case ConsoleMessageLevel.WARNING:
        return const Color(0xFFFF9800);
      case ConsoleMessageLevel.DEBUG:
        return const Color(0xFF2196F3);
      case ConsoleMessageLevel.LOG:
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF000000);
    }
  }
  
  /// Get text representation of message level
  String get levelText {
    switch (level) {
      case ConsoleMessageLevel.ERROR:
        return 'ERROR';
      case ConsoleMessageLevel.WARNING:
        return 'WARN';
      case ConsoleMessageLevel.DEBUG:
        return 'DEBUG';
      case ConsoleMessageLevel.LOG:
        return 'LOG';
      default:
        return 'INFO';
    }
  }
}