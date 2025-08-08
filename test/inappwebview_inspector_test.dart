import 'package:flutter_test/flutter_test.dart';
import 'package:inappwebview_inspector/inappwebview_inspector.dart';

void main() {
  group('WebView Inspector', () {
    test('can create script history', () {
      final history = InAppWebViewInspectorScriptHistory(
        script: 'console.log("test")',
        timestamp: DateTime.now(),
      );

      expect(history.script, 'console.log("test")');
      expect(history.usageCount, 1);
    });

    test('script history can be serialized', () {
      final history = InAppWebViewInspectorScriptHistory(
        script: 'document.title',
        timestamp: DateTime.now(),
        usageCount: 5,
      );

      final json = history.toJson();
      final restored = InAppWebViewInspectorScriptHistory.fromJson(json);

      expect(restored.script, history.script);
      expect(restored.usageCount, history.usageCount);
    });

    test('script history manager initializes with default scripts', () {
      final manager = InAppWebViewInspectorScriptHistoryManager();
      final history = manager.history;

      expect(history.isNotEmpty, true);
      expect(
          history.any((h) => h.script == 'console.log("Hello World");'), true);
      expect(history.any((h) => h.script == 'document.title'), true);
    });

    test('script history manager can add new scripts', () {
      final manager = InAppWebViewInspectorScriptHistoryManager();
      final initialCount = manager.history.length;

      // Use a unique script that's definitely not in defaults
      final uniqueScript =
          'console.warn("unique test script ${DateTime.now().millisecondsSinceEpoch}");';
      manager.addScript(uniqueScript);

      // Since maxHistoryCount is 15 and we start with 15 default scripts,
      // adding a new one will maintain the count at 15 but should contain our script
      expect(manager.history.length, initialCount);
      expect(manager.history.any((h) => h.script == uniqueScript), true);
    });

    test('script history manager increases usage count for existing scripts',
        () {
      final manager = InAppWebViewInspectorScriptHistoryManager();

      // Add the same script twice
      manager.addScript('document.title');
      final firstCount = manager.history
          .firstWhere((h) => h.script == 'document.title')
          .usageCount;

      manager.addScript('document.title');
      final secondCount = manager.history
          .firstWhere((h) => h.script == 'document.title')
          .usageCount;

      expect(secondCount, greaterThan(firstCount));
    });

    test('script history manager can clear history', () {
      final manager = InAppWebViewInspectorScriptHistoryManager();

      manager.addScript('test script');
      manager.clearHistory();

      // Should reset to defaults, not completely empty
      expect(manager.history.isNotEmpty, true);
      expect(manager.history.any((h) => h.script == 'test script'), false);
      expect(
          manager.history.any((h) => h.script == 'console.log("Hello World");'),
          true);
    });
  });
}
