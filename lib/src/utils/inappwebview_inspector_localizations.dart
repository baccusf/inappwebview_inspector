/// Localization support for WebView Inspector
class InAppWebViewInspectorLocalizations {
  final String activeWebView;
  final String javascriptPlaceholder;
  final String execute;
  final String history;
  final String consoleOutput;
  final String noHistory;
  final String noWebViewAvailable;

  const InAppWebViewInspectorLocalizations({
    required this.activeWebView,
    required this.javascriptPlaceholder,
    required this.execute,
    required this.history,
    required this.consoleOutput,
    required this.noHistory,
    required this.noWebViewAvailable,
  });

  /// English localization (default)
  static const InAppWebViewInspectorLocalizations english =
      InAppWebViewInspectorLocalizations(
    activeWebView: 'Active WebView:',
    javascriptPlaceholder: 'Enter JavaScript...',
    execute: 'Execute',
    history: 'History',
    consoleOutput: 'Console Output',
    noHistory: 'No history available.',
    noWebViewAvailable: 'No WebView available',
  );

  /// Korean localization
  static const InAppWebViewInspectorLocalizations korean =
      InAppWebViewInspectorLocalizations(
    activeWebView: '활성화된 웹뷰:',
    javascriptPlaceholder: 'JavaScript를 입력해주세요...',
    execute: '실행',
    history: '히스토리',
    consoleOutput: 'Console Output',
    noHistory: '히스토리가 없습니다.',
    noWebViewAvailable: '웹뷰가 없습니다',
  );

  /// Japanese localization
  static const InAppWebViewInspectorLocalizations japanese =
      InAppWebViewInspectorLocalizations(
    activeWebView: 'アクティブWebView:',
    javascriptPlaceholder: 'JavaScriptを入力してください...',
    execute: '実行',
    history: '履歴',
    consoleOutput: 'コンソール出力',
    noHistory: '履歴がありません。',
    noWebViewAvailable: 'WebViewがありません',
  );

  /// Spanish localization
  static const InAppWebViewInspectorLocalizations spanish =
      InAppWebViewInspectorLocalizations(
    activeWebView: 'WebView Activo:',
    javascriptPlaceholder: 'Ingrese JavaScript...',
    execute: 'Ejecutar',
    history: 'Historial',
    consoleOutput: 'Salida de Consola',
    noHistory: 'No hay historial disponible.',
    noWebViewAvailable: 'WebView no disponible',
  );

  /// French localization
  static const InAppWebViewInspectorLocalizations french =
      InAppWebViewInspectorLocalizations(
    activeWebView: 'WebView Active:',
    javascriptPlaceholder: 'Entrez du JavaScript...',
    execute: 'Exécuter',
    history: 'Historique',
    consoleOutput: 'Sortie Console',
    noHistory: 'Aucun historique disponible.',
    noWebViewAvailable: 'Aucune WebView disponible',
  );

  /// German localization
  static const InAppWebViewInspectorLocalizations german =
      InAppWebViewInspectorLocalizations(
    activeWebView: 'Aktive WebView:',
    javascriptPlaceholder: 'JavaScript eingeben...',
    execute: 'Ausführen',
    history: 'Verlauf',
    consoleOutput: 'Konsolen-Ausgabe',
    noHistory: 'Kein Verlauf verfügbar.',
    noWebViewAvailable: 'Keine WebView verfügbar',
  );

  /// Chinese Simplified localization
  static const InAppWebViewInspectorLocalizations chineseSimplified =
      InAppWebViewInspectorLocalizations(
    activeWebView: '活动WebView:',
    javascriptPlaceholder: '输入JavaScript...',
    execute: '执行',
    history: '历史记录',
    consoleOutput: '控制台输出',
    noHistory: '没有历史记录。',
    noWebViewAvailable: '没有可用的WebView',
  );

  /// Portuguese localization
  static const InAppWebViewInspectorLocalizations portuguese =
      InAppWebViewInspectorLocalizations(
    activeWebView: 'WebView Ativa:',
    javascriptPlaceholder: 'Digite JavaScript...',
    execute: 'Executar',
    history: 'Histórico',
    consoleOutput: 'Saída do Console',
    noHistory: 'Nenhum histórico disponível.',
    noWebViewAvailable: 'WebView não disponível',
  );

  /// Get localization by language code
  static InAppWebViewInspectorLocalizations getByLanguageCode(
      String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'ko':
      case 'ko_kr':
        return korean;
      case 'ja':
      case 'ja_jp':
        return japanese;
      case 'es':
      case 'es_es':
        return spanish;
      case 'fr':
      case 'fr_fr':
        return french;
      case 'de':
      case 'de_de':
        return german;
      case 'zh':
      case 'zh_cn':
        return chineseSimplified;
      case 'pt':
      case 'pt_br':
        return portuguese;
      case 'en':
      case 'en_us':
      default:
        return english;
    }
  }
}
