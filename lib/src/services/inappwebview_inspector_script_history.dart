import '../utils/inappwebview_inspector_constants.dart';

/// 스크립트 히스토리 엔트리
class InAppWebViewInspectorScriptHistory {
  final String script;
  final DateTime timestamp;
  final int usageCount;

  const InAppWebViewInspectorScriptHistory({
    required this.script,
    required this.timestamp,
    this.usageCount = InAppWebViewInspectorConstants.defaultUsageCount,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'script': script,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'usageCount': usageCount,
    };
  }

  /// Create from JSON
  factory InAppWebViewInspectorScriptHistory.fromJson(
      Map<String, dynamic> json) {
    return InAppWebViewInspectorScriptHistory(
      script: json['script'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      usageCount: json['usageCount'] as int? ??
          InAppWebViewInspectorConstants.defaultUsageCount,
    );
  }

  /// Create new instance with increased usage count
  InAppWebViewInspectorScriptHistory increaseUsage() {
    return InAppWebViewInspectorScriptHistory(
      script: script,
      timestamp: DateTime.now(), // Update to latest usage time
      usageCount: usageCount + InAppWebViewInspectorConstants.defaultUsageCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InAppWebViewInspectorScriptHistory &&
        other.script == script;
  }

  @override
  int get hashCode => script.hashCode;

  @override
  String toString() {
    return 'InAppWebViewInspectorScriptHistory(script: ${script.length > InAppWebViewInspectorConstants.scriptMaxDisplayLength ? '${script.substring(0, InAppWebViewInspectorConstants.scriptMaxDisplayLength)}...' : script}, timestamp: $timestamp, usageCount: $usageCount)';
  }
}
