import 'inappwebview_inspector_script_history.dart';
import '../utils/inappwebview_inspector_constants.dart';

/// WebView inspector script history manager - Memory only storage
class InAppWebViewInspectorScriptHistoryManager {
  static const int _maxHistoryCount =
      InAppWebViewInspectorConstants.maxHistoryCount;

  /// Default frequently used scripts
  static final List<String> _defaultScripts = [
    'console.log("Hello World");',
    'document.title',
    'document.body.innerHTML',
    'window.location.href',
    'document.cookie',
    'localStorage.getItem("key")',
    'sessionStorage.getItem("key")',
    'document.querySelector("selector")',
    'document.querySelectorAll("selector")',
    'window.innerWidth + "x" + window.innerHeight',
    'navigator.userAgent',
    'document.readyState',
    'Object.keys(window)',
    'document.getElementsByTagName("*").length',
    'performance.now()',
  ];

  List<InAppWebViewInspectorScriptHistory> _history = [];

  /// Create ScriptHistoryManager instance with optional initial scripts
  InAppWebViewInspectorScriptHistoryManager({List<String>? initialScripts}) {
    _initializeWithDefaults(initialScripts);
  }

  /// Initialize with default scripts and optional additional scripts
  void _initializeWithDefaults(List<String>? additionalScripts) {
    final now = DateTime.now();

    // Add default scripts with decreasing usage counts (most useful first)
    for (int i = 0; i < _defaultScripts.length; i++) {
      _history.add(InAppWebViewInspectorScriptHistory(
        script: _defaultScripts[i],
        timestamp: now.subtract(Duration(minutes: i)),
        usageCount:
            _defaultScripts.length - i, // Higher count for earlier scripts
      ));
    }

    // Add any additional initial scripts
    if (additionalScripts != null) {
      for (final script in additionalScripts) {
        if (script.trim().isNotEmpty && !_containsScript(script.trim())) {
          _history.add(InAppWebViewInspectorScriptHistory(
            script: script.trim(),
            timestamp: now,
            usageCount: InAppWebViewInspectorConstants.defaultUsageCount,
          ));
        }
      }
    }

    _sortHistory();
  }

  /// Check if script already exists in history
  bool _containsScript(String script) {
    return _history.any((h) => h.script == script);
  }

  /// Sort history by usage frequency and recency
  void _sortHistory() {
    _history.sort((a, b) {
      final usageComparison = b.usageCount.compareTo(a.usageCount);
      if (usageComparison != InAppWebViewInspectorConstants.compareEqual) {
        return usageComparison;
      }
      return b.timestamp.compareTo(a.timestamp);
    });
  }

  /// Get current history list (latest first)
  List<InAppWebViewInspectorScriptHistory> get history =>
      List.unmodifiable(_history);

  /// Get current history list (latest first) as Future for compatibility
  Future<List<InAppWebViewInspectorScriptHistory>> getHistory() async =>
      List.unmodifiable(_history);

  /// Add script to history
  void addScript(String script) {
    if (script.trim().isEmpty) {
      return;
    }

    final trimmedScript = script.trim();

    // Check if the same script already exists
    final existingIndex = _history.indexWhere((h) => h.script == trimmedScript);

    if (existingIndex != InAppWebViewInspectorConstants.notFoundIndex) {
      // Increase usage count and update timestamp for existing script
      final existing = _history[existingIndex];
      _history[existingIndex] = existing.increaseUsage();
    } else {
      // Add new script
      _history.add(InAppWebViewInspectorScriptHistory(
        script: trimmedScript,
        timestamp: DateTime.now(),
      ));
    }

    _sortHistory();

    // Limit maximum count
    if (_history.length > _maxHistoryCount) {
      _history = _history.take(_maxHistoryCount).toList();
    }
  }

  /// Remove script from history
  void removeScript(String script) {
    _history.removeWhere((h) => h.script == script);
  }

  /// Clear all history (keeps default scripts)
  void clearHistory() {
    _history.clear();
    _initializeWithDefaults(null); // Reinitialize with defaults
  }

  /// Clear all history including defaults
  void clearAllHistory() {
    _history.clear();
  }

  /// Search scripts (partial match)
  List<InAppWebViewInspectorScriptHistory> searchScripts(String query) {
    if (query.trim().isEmpty) {
      return history;
    }

    final lowercaseQuery = query.toLowerCase();
    return _history
        .where((h) => h.script.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  /// Reset to default scripts only
  void resetToDefaults() {
    _history.clear();
    _initializeWithDefaults(null);
  }

  /// Add custom default scripts (useful for specific app needs)
  void addCustomDefaults(List<String> customScripts) {
    final now = DateTime.now();

    for (final script in customScripts) {
      if (script.trim().isNotEmpty && !_containsScript(script.trim())) {
        _history.add(InAppWebViewInspectorScriptHistory(
          script: script.trim(),
          timestamp: now,
          usageCount: InAppWebViewInspectorConstants.defaultUsageCount +
              1, // Slightly higher than default
        ));
      }
    }

    _sortHistory();
  }
}
