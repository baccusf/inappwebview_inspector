import 'dart:async';
import 'package:flutter/material.dart';
import 'inappwebview_inspector_widget.dart';
import '../core/inappwebview_inspector_interface.dart';

/// Overlay manager for automatic UI injection in development mode
class InAppWebViewInspectorOverlayManager {
  static OverlayEntry? _overlayEntry;
  static BuildContext? _discoveredContext;
  static Timer? _contextSearchTimer;
  static bool _initialized = false;
  static bool _setupGuidanceShown = false;

  /// Show inspector with automatic context discovery
  static void showInspector({
    InAppWebViewInspectorInterface? inspector,
    InAppWebViewInspectorConfig? config,
  }) {
    // If already visible, do nothing
    if (_overlayEntry != null) return;

    if (!_initialized) {
      _autoInitialize(inspector: inspector, config: config);
    } else {
      _createOverlayIfContextAvailable(inspector: inspector, config: config);
    }
  }

  /// Hide inspector overlay
  static void hideInspector() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _contextSearchTimer?.cancel();
    _contextSearchTimer = null;
  }

  /// Check if inspector is currently visible
  static bool get isVisible => _overlayEntry != null;

  /// Initialize automatic context discovery system
  static void _autoInitialize({
    InAppWebViewInspectorInterface? inspector,
    InAppWebViewInspectorConfig? config,
  }) {
    if (_initialized) return;
    _initialized = true;

    // Try immediate context discovery
    final context = _discoverActiveContext();
    if (context != null) {
      _discoveredContext = context;
      _createOverlay(context, inspector: inspector, config: config);
      return;
    }

    // Start periodic context search
    _startContextSearch(inspector: inspector, config: config);
  }

  /// Start periodic context search with retry mechanism
  static void _startContextSearch({
    InAppWebViewInspectorInterface? inspector,
    InAppWebViewInspectorConfig? config,
  }) {
    var attempts = 0;
    const maxAttempts = 50; // 5 seconds with 100ms intervals

    _contextSearchTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      attempts++;

      final context = _discoverActiveContext();
      if (context != null) {
        _discoveredContext = context;
        timer.cancel();
        _createOverlay(context, inspector: inspector, config: config);
        return;
      }

      // After max attempts, show guidance and stop searching
      if (attempts >= maxAttempts) {
        timer.cancel();
        _showSetupGuidance();
      }
    });
  }

  /// Register NavigatorKey for optimal context access
  static GlobalKey<NavigatorState>? _navigatorKey;

  static void registerNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  /// Discover active BuildContext automatically
  static BuildContext? _discoverActiveContext() {
    try {
      // Method 0: Try NavigatorKey first (most reliable if provided)
      if (_navigatorKey?.currentContext != null) {
        final context = _navigatorKey!.currentContext!;
        try {
          Overlay.of(context);
          return context;
        } catch (e) {
          // NavigatorKey context doesn't have overlay, continue with other methods
        }
      }

      // Method 1: Try to get context from focus system
      final binding = WidgetsBinding.instance;
      final focusManager = binding.focusManager;
      final primaryFocus = focusManager.primaryFocus;
      if (primaryFocus?.context != null) {
        final context = primaryFocus!.context!;
        // Verify context has overlay capability
        try {
          Overlay.of(context);
          return context;
        } catch (e) {
          // This context doesn't have overlay, continue searching
        }
      }

      // Method 3: Try to get context from BuildOwner if available
      final buildOwner = binding.buildOwner;
      if (buildOwner != null) {
        // Use a simpler approach to find a valid context
        try {
          final focusNode = binding.focusManager.rootScope;
          if (focusNode.context != null) {
            final context = focusNode.context!;
            try {
              Overlay.of(context);
              return context;
            } catch (e) {
              // Continue searching
            }
          }
        } catch (e) {
          // Continue with other methods
        }
      }
    } catch (e) {
      // Context discovery failed, will retry
      // Context discovery attempt failed, will retry
      // Debug output controlled by config in calling methods
    }

    return null;
  }

  /// Create overlay entry with the discovered context
  static void _createOverlay(
    BuildContext context, {
    InAppWebViewInspectorInterface? inspector,
    InAppWebViewInspectorConfig? config,
  }) {
    try {
      _overlayEntry = OverlayEntry(
        builder: (context) => InAppWebViewInspectorWidget(
          inspector: inspector,
          config: config,
        ),
      );

      final overlay = Overlay.of(context);
      overlay.insert(_overlayEntry!);

      final effectiveConfig =
          config ?? InAppWebViewInspectorConfig.defaultConfig;
      if (effectiveConfig.debugMode) {
        debugPrint(
            '🎉 InAppWebViewInspector: Auto-setup successful! Inspector is now available.');
      }
    } catch (e) {
      // Failed to create overlay, show guidance
      debugPrint('InAppWebViewInspector: Failed to create overlay: $e');
      _overlayEntry = null;
      _showSetupGuidance();
    }
  }

  /// Create overlay if context is available, otherwise start discovery
  static void _createOverlayIfContextAvailable({
    InAppWebViewInspectorInterface? inspector,
    InAppWebViewInspectorConfig? config,
  }) {
    if (_discoveredContext != null) {
      _createOverlay(_discoveredContext!, inspector: inspector, config: config);
    } else {
      _startContextSearch(inspector: inspector, config: config);
    }
  }

  /// Show setup guidance for developers
  static void _showSetupGuidance() {
    if (_setupGuidanceShown) return;
    _setupGuidanceShown = true;

    debugPrint('''
🔧 InAppWebViewInspector: Auto-setup needs help!

For optimal experience, add this line to your MaterialApp:
  navigatorKey: InAppWebViewInspector.navigatorKey,

Example:
MaterialApp(
  navigatorKey: InAppWebViewInspector.navigatorKey,
  home: MyHomePage(),
)

The inspector will keep trying automatically in the background...
    ''');
  }

  /// Reset initialization state (useful for hot reload)
  static void reset() {
    _initialized = false;
    _setupGuidanceShown = false;
    _discoveredContext = null;
    hideInspector();
  }

  /// Dispose all resources
  static void dispose() {
    hideInspector();
    reset();
  }
}
