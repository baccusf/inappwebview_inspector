import 'package:flutter/foundation.dart';
import '../services/inappwebview_inspector_script_history_manager.dart';
import '../services/inappwebview_inspector_script_history.dart';

// 스크립트 히스토리 컨트롤러
class InAppWebViewInspectorScriptHistoryController with ChangeNotifier {
  final InAppWebViewInspectorScriptHistoryManager _historyManager;
  List<InAppWebViewInspectorScriptHistory> _history = [];

  InAppWebViewInspectorScriptHistoryController(this._historyManager) {
    _loadHistory();
  }

  List<InAppWebViewInspectorScriptHistory> get history => _history;

  void _loadHistory() {
    _history = _historyManager.history;
    notifyListeners();
  }

  void addScript(String script) {
    if (script.trim().isEmpty) return;

    _historyManager.addScript(script.trim());
    _loadHistory(); // 히스토리 새로고침
  }

  void clearHistory() {
    _historyManager.clearHistory();
    _loadHistory(); // 기본 스크립트들로 다시 로드
  }

  void clearAllHistory() {
    _historyManager.clearAllHistory();
    _loadHistory();
  }

  void resetToDefaults() {
    _historyManager.resetToDefaults();
    _loadHistory();
  }
}
