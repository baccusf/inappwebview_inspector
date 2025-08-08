# WebView Inspector Localization Demo

This document demonstrates how to use the WebView Inspector with different languages.

## Quick Test

Change the localization in `main.dart`:

```dart
void main() {
  InAppWebViewInspector.initializeDevelopment(
    enableScriptHistory: true,
    maxScriptHistoryCount: 25,
    localizations: InAppWebViewInspectorLocalizations.korean, // Try different languages
  );
  
  runApp(const MyApp());
}
```

## Available Languages

### English (Default)
```dart
localizations: InAppWebViewInspectorLocalizations.english,
```
- Active WebView: "Active WebView:"
- JavaScript Placeholder: "Enter JavaScript..."
- Execute: "Execute"
- History: "History"
- Console Output: "Console Output"

### Korean
```dart
localizations: InAppWebViewInspectorLocalizations.korean,
```
- Active WebView: "활성화된 웹뷰:"
- JavaScript Placeholder: "JavaScript를 입력해주세요..."
- Execute: "실행"
- History: "히스토리"
- Console Output: "Console Output"

### Japanese
```dart
localizations: InAppWebViewInspectorLocalizations.japanese,
```
- Active WebView: "アクティブWebView:"
- JavaScript Placeholder: "JavaScriptを入力してください..."
- Execute: "実行"
- History: "履歴"
- Console Output: "コンソール出力"

### Spanish
```dart
localizations: InAppWebViewInspectorLocalizations.spanish,
```
- Active WebView: "WebView Activo:"
- JavaScript Placeholder: "Ingrese JavaScript..."
- Execute: "Ejecutar"
- History: "Historial"
- Console Output: "Salida de Consola"

### French
```dart
localizations: InAppWebViewInspectorLocalizations.french,
```
- Active WebView: "WebView Active:"
- JavaScript Placeholder: "Entrez du JavaScript..."
- Execute: "Exécuter"
- History: "Historique"
- Console Output: "Sortie Console"

### German
```dart
localizations: InAppWebViewInspectorLocalizations.german,
```
- Active WebView: "Aktive WebView:"
- JavaScript Placeholder: "JavaScript eingeben..."
- Execute: "Ausführen"
- History: "Verlauf"
- Console Output: "Konsolen-Ausgabe"

### Chinese Simplified
```dart
localizations: InAppWebViewInspectorLocalizations.chineseSimplified,
```
- Active WebView: "活动WebView:"
- JavaScript Placeholder: "输入JavaScript..."
- Execute: "执行"
- History: "历史记录"
- Console Output: "控制台输出"

### Portuguese
```dart
localizations: InAppWebViewInspectorLocalizations.portuguese,
```
- Active WebView: "WebView Ativa:"
- JavaScript Placeholder: "Digite JavaScript..."
- Execute: "Executar"
- History: "Histórico"
- Console Output: "Saída do Console"

## Language Code Detection

You can also use automatic language detection:

```dart
import 'dart:ui' as ui;

void main() {
  // Get system language and automatically select localization
  final systemLocale = ui.PlatformDispatcher.instance.locale.languageCode;
  final localizations = InAppWebViewInspectorLocalizations.getByLanguageCode(systemLocale);
  
  InAppWebViewInspector.initializeDevelopment(
    enableScriptHistory: true,
    maxScriptHistoryCount: 25,
    localizations: localizations,
  );
  
  runApp(const MyApp());
}
```

## Custom Configuration

For advanced usage with custom configuration:

```dart
void main() {
  InAppWebViewInspector.initializeWithConfig(
    InspectorConfig(
      debugMode: true,
      maxConsoleLogCount: 1000,
      enableScriptHistory: true,
      maxScriptHistoryCount: 20,
      localizations: InAppWebViewInspectorLocalizations.korean, // Your preferred language
      onScriptExecuted: (script, webViewId) {
        print('Script executed: $script');
      },
    ),
  );
  
  runApp(const MyApp());
}
```

## Testing Different Languages

1. Open `example/lib/main.dart`
2. Change the `localizations` parameter to any of the available languages
3. Run the app with `fvm flutter run`
4. Open the WebView Inspector to see the localized UI

The interface will display all text in your selected language, including:
- WebView selector dropdown
- JavaScript input placeholder
- Execute button
- History popup
- Console output header
- Error/status messages