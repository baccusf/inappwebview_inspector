// Core exports
export 'src/core/inappwebview_inspector.dart';
export 'src/core/inappwebview_inspector_interface.dart';
export 'src/core/inappwebview_inspector_factory.dart';

// Services exports
export 'src/services/inappwebview_inspector_script_history.dart';
export 'src/services/inappwebview_inspector_script_history_manager.dart';

// UI exports
export 'src/ui/inappwebview_inspector_widget.dart';
export 'src/ui/inappwebview_inspector_overlay_manager.dart';
export 'src/ui/inappwebview_inspector_focus_controller.dart';
export 'src/ui/inappwebview_inspector_script_history_controller.dart';

// Utils exports
export 'src/utils/inappwebview_inspector_constants.dart';
export 'src/utils/inappwebview_inspector_localizations.dart';
export 'src/utils/inappwebview_inspector_script_utils.dart';

/// WebView Inspector - A powerful debugging tool for flutter_inappwebview
///
/// This library provides real-time console monitoring, JavaScript execution,
/// and script history management with a draggable overlay interface.
///
/// ## Quick Start (Simple & Intuitive)
///
/// ```dart
/// // Initialize the inspector
/// InAppWebViewInspector.initializeDevelopment();
///
/// // Register your WebView
/// InAppWebView(
///   onWebViewCreated: (controller) {
///     InAppWebViewInspector.registerWebView('main', controller, url);
///   },
///   onConsoleMessage: (controller, consoleMessage) {
///     InAppWebViewInspector.addConsoleLog('main', consoleMessage);
///   },
/// )
///
/// // Show inspector anywhere - UI automatically appears!
/// InAppWebViewInspector.show(); // Always auto-injects UI
/// ```
///
/// ## Optimal Setup (Best Performance)
///
/// ```dart
/// MaterialApp(
///   navigatorKey: InAppWebViewInspector.navigatorKey, // Add for instant context access
///   home: MyHomePage(),
/// )
/// ```
///
/// ## Features
///
/// - 🔍 Real-time console log monitoring
/// - ⚡ JavaScript execution and result display
/// - 📜 Script history with usage frequency tracking
/// - 🎯 Multiple WebView support with selector
/// - 🎨 Draggable overlay interface
/// - ⚙️ Configurable settings and callbacks
///
/// ## Configuration
///
/// ```dart
/// InAppWebViewInspector.initialize(
///   debugMode: true,
///   maxConsoleLogCount: 500,
///   enableScriptHistory: true,
///   onScriptExecuted: (script, webViewId) {
///     print('Executed: $script on $webViewId');
///   },
/// );
/// ```
