# InAppWebView Inspector 🔍

[![pub package](https://img.shields.io/pub/v/inappwebview_inspector.svg)](https://pub.dev/packages/inappwebview_inspector)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

`flutter_inappwebview`のための強力なWebViewデバッグ・検査ツールです。リアルタイムコンソールモニタリング、JavaScript実行、スクリプト履歴管理をドラッグ可能なオーバーレイインターフェイスで提供します。

> 🤖 **Claudeと共同開発**: このFlutterライブラリは、Claude AIとの**バイブコーディング（Vibe coding）**手法を用いた協働により開発され、AI支援開発と人間-AI協力プログラミングの力を実証しています。

## 🌍 多言語ドキュメント

- [English](README.md) | [한국어](README_ko.md) | **日本語**

## ✨ 主要機能

### 🖥️ **リアルタイムコンソールモニタリング**
- **ライブコンソール出力**: すべてのJavaScriptコンソールメッセージ（`log`、`warn`、`error`、`debug`）をリアルタイムで監視
- **色分けされたメッセージ**: ログレベルに応じた色分けで簡単に識別可能
- **タイムスタンプ表示**: 各メッセージに正確なタイムスタンプ情報を含む
- **マルチライン対応**: 長いメッセージとマルチライン出力を完全サポート
- **クリーンなインターフェース**: 不要なラベルを削除し、ストリームラインされたデバッグ体験

### 🚀 **強化されたJavaScript実行**
- **インタラクティブコンソール**: 知的な結果処理とともにWebViewで直接JavaScriptコードを実行
- **スマートDOMオブジェクト処理**: 
  - `document.querySelector("h1")` → 要素の詳細情報を表示（タグ、id、クラス、テキスト内容）
  - `document.querySelectorAll("p")` → マッチするすべての要素の包括的な情報を一覧表示
  - `document.body.classList` → 自動的に読みやすい配列形式に変換
  - 関数や複雑なオブジェクト → 開発者フレンドリーな形式で表示
- **強化されたエラー処理**: 一般的なDOM操作に対する有用な提案を含む包括的なエラーメッセージ
- **Unicode・Base64サポート**: 複雑なシナリオ用の高度なスクリプトエンコーディングオプション

### 📚 **インテリジェントスクリプト履歴システム**
- **プリロードされたスクリプト**: すぐに使える15個以上の一般的に使用されるJavaScriptスニペット
- **使用頻度ベースの並び替え**: 最も使用されたスクリプトが自動的に上位に表示
- **メモリベースストレージ**: ファイルI/Oなしの高速で軽量な履歴管理
- **スマート提案**: コンテキストに応じたスクリプト推奨
- **使用量追跡**: よく使用するスクリプトを自動的に追跡し、優先度を設定

### 🎯 **マルチWebView管理**
- **マルチWebViewサポート**: 単一アプリケーション内で無制限のWebViewを処理
- **簡単切り替え**: 登録されたWebView間の迅速なドロップダウン切り替え
- **個別監視**: 各WebViewが独自のコンソールと実行コンテキストを維持
- **自動登録**: WebViewインスタンスの登録と管理のためのシンプルなAPI

### 🌍 **包括的な国際化**
- **8言語対応**: 英語、韓国語、日本語、スペイン語、フランス語、ドイツ語、中国語（簡体字）、ポルトガル語
- **自動検出**: システムロケールからの自動言語検出
- **簡単なローカライゼーション**: 言語設定のためのシンプルなAPI
- **一貫したUI**: すべてのインターフェイス要素の適切なローカライゼーション

### 🎨 **高度なユーザーインターフェース**
- **ドラッグ可能オーバーレイ**: スムーズなドラッグインタラクションで画面上のどこにでもインスペクターを移動可能
- **リサイザブルインターフェース**: さまざまな用途に対応するコンパクトモードと最大化モードの切り替え
- **SafeArea対応**: デバイス画面制約とノッチに自動調整
- **スタックベースアーキテクチャ**: オーバーレイ競合のない安定したポップアップシステム
- **クリーンなデザイン**: 生産性のために最適化されたミニマルで開発者中心のインターフェース

## 📦 インストール

`pubspec.yaml`ファイルに以下を追加してください：

```yaml
dependencies:
  inappwebview_inspector: ^0.1.0
  flutter_inappwebview: ^6.0.0
```

その後実行してください：

```bash
$ flutter pub get
```

## 🚀 クイックスタート

### 1. インスペクターの初期化

`main()`関数に以下を追加してください：

```dart
import 'package:inappwebview_inspector/inappwebview_inspector.dart';

void main() {
  // 拡張機能付きの開発用初期化
  InAppWebViewInspector.initializeDevelopment(
    enableScriptHistory: true,
    maxScriptHistoryCount: 25,
    localizations: InAppWebViewInspectorLocalizations.japanese, // 必要に応じて変更
    onScriptExecuted: (script, webViewId) {
      print('$webViewIdで実行: $script');
    },
    onConsoleLog: (log) {
      print('コンソール [${log.levelText}]: ${log.message}');
    },
  );
  
  runApp(MyApp());
}
```

### 2. アプリにインスペクターウィジェットを追加

**⚠️ 重要**: インスペクターウィジェットは、`Scaffold`のボディ内の`Stack`の中に配置する必要があります：

```dart
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:inappwebview_inspector/inappwebview_inspector.dart';

class MyWebViewPage extends StatefulWidget {
  @override
  _MyWebViewPageState createState() => _MyWebViewPageState();
}

class _MyWebViewPageState extends State<MyWebViewPage> {
  InAppWebViewController? webViewController;
  final String webViewId = 'main_webview';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebView with Inspector'),
        actions: [
          // インスペクター用トグルボタン
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: InAppWebViewInspector.toggle,
            tooltip: 'インスペクタートグル',
          ),
        ],
      ),
      body: Stack(  // ⚠️ ここでStackを使用必須
        children: [
          // メインWebView
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri('https://flutter.dev'),
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
              
              // インスペクターにWebViewを登録
              InAppWebViewInspector.registerWebView(
                webViewId,
                controller,
                'https://flutter.dev',
              );
            },
            onLoadStop: (controller, url) {
              // ナビゲーション発生時にインスペクターでURL更新
              if (url != null) {
                InAppWebViewInspector.updateWebViewUrl(
                  webViewId,
                  url.toString(),
                );
              }
            },
            onConsoleMessage: (controller, consoleMessage) {
              // コンソールメッセージをインスペクターに転送
              InAppWebViewInspector.addConsoleLog(
                webViewId,
                consoleMessage,
              );
            },
            initialSettings: InAppWebViewSettings(
              isInspectable: true, // デバッグ有効化
              javaScriptEnabled: true,
              domStorageEnabled: true,
            ),
          ),
          
          // インスペクターオーバーレイウィジェット - Stack内に配置必須
          const InAppWebViewInspectorWidget(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // ページ破棄時のクリーンアップ
    InAppWebViewInspector.unregisterWebView(webViewId);
    super.dispose();
  }
}
```

### 3. インスペクター表示制御

```dart
// インスペクター表示/非表示
InAppWebViewInspector.show();
InAppWebViewInspector.hide();
InAppWebViewInspector.toggle();

// インスペクター有効/無効
InAppWebViewInspector.enable();
InAppWebViewInspector.disable();

// ステータス確認
bool isVisible = InAppWebViewInspector.isVisible;
bool isEnabled = InAppWebViewInspector.isEnabled;
```

## ⚙️ 設定オプション

### 開発モード（デバッグビルド推奨）

```dart
InAppWebViewInspector.initializeDevelopment(
  enableScriptHistory: true,
  maxScriptHistoryCount: 25,
  maxConsoleLogCount: 500,
  localizations: InAppWebViewInspectorLocalizations.japanese,
  onScriptExecuted: (script, webViewId) {
    print('$webViewIdでスクリプト実行: $script');
  },
  onConsoleLog: (log) {
    print('コンソール [${log.levelText}]: ${log.message}');
  },
);
```

### プロダクションモード（最小限の影響）

```dart
InAppWebViewInspector.initializeProduction(
  maxConsoleLogCount: 50,
  enableAutoResultLogging: false,
  enableScriptHistory: false,
  localizations: InAppWebViewInspectorLocalizations.japanese,
);
```

### 高度なカスタム設定

```dart
InAppWebViewInspector.initializeWithConfig(
  InAppWebViewInspectorConfig(
    debugMode: true,
    maxConsoleLogCount: 1000,
    enableAutoResultLogging: true,
    enableUnicodeQuoteNormalization: true,
    enableBase64ScriptEncoding: true,
    enableScriptHistory: true,
    maxScriptHistoryCount: 30,
    localizations: InAppWebViewInspectorLocalizations.japanese, // 多言語サポート
    onScriptExecuted: (script, webViewId) {
      // カスタムスクリプト実行コールバック
      analytics.logEvent('script_executed', {'webview_id': webViewId});
    },
    onConsoleLog: (log) {
      // カスタムコンソールロギング
      if (log.level == ConsoleMessageLevel.ERROR) {
        crashlytics.recordError(log.message, null);
      }
    },
    onError: (error, webViewId) {
      // エラー処理コールバック
      print('$webViewIdでインスペクターエラー: $error');
    },
  ),
);
```

## 🛠️ プリロードされたユーティリティスクリプト

インスペクターには15個以上のすぐに使えるJavaScriptスニペットが含まれています：

### ページ情報
- `document.title` - 現在のページタイトル取得
- `window.location.href` - 現在のURL取得
- `document.readyState` - ページ読み込み状態確認
- `document.getElementsByTagName("*").length` - 全要素数カウント

### DOM操作  
- `document.querySelector("selector")` - 詳細情報付きで単一要素検索
- `document.querySelectorAll("selector")` - マッチする全要素検索
- `document.body.innerHTML` - ページHTML内容取得
- `document.cookie` - 全クッキー表示

### ブラウザ・パフォーマンス
- `navigator.userAgent` - ブラウザ情報取得
- `window.innerWidth + "x" + window.innerHeight` - ビューポートサイズ取得
- `performance.now()` - 高精度タイミング
- `Object.keys(window)` - グローバル変数一覧

### ストレージアクセス
- `localStorage.getItem("key")` - ローカルストレージアクセス
- `sessionStorage.getItem("key")` - セッションストレージアクセス

### 開発ユーティリティ
- `console.log("Hello World");` - 基本コンソールロギング

## 📸 スクリーンショット

### iOS インスペクターインターフェース
<img src="screenshots/ios_inspector_demo.png" width="300" alt="iOS WebView Inspector Demo">

*ドラッグ可能なオーバーレイインターフェースを表示するiOSで動作中のインスペクター*

### Android インスペクターインターフェース  
<img src="screenshots/android_inspector_demo.png" width="300" alt="Android WebView Inspector Demo">

*同じ強力なデバッグ機能を提供するAndroidで動作中のインスペクター*

### 表示された主要インターフェース機能:
- **🖱️ ドラッグ可能オーバーレイ**: 画面上のどこでもインスペクターを移動可能
- **📱 レスポンシブデザイン**: 異なる画面サイズと方向に適応  
- **🎯 WebViewセレクター**: 複数のWebView間を切り替えるドロップダウン
- **⌨️ インタラクティブコンソール**: 履歴ドロップダウン付きJavaScript入力フィールド
- **📋 リアルタイムログ**: タイムスタンプ付きの色分けされたコンソール出力
- **🔄 リサイザブルインターフェース**: コンパクトモードと最大化モード間の切り替え

## ⚠️ 重要な実装注意事項

### ウィジェット配置要件

`InAppWebViewInspectorWidget`は、ランタイムエラーを防ぐために正しく配置する必要があります：

✅ **正しい**: ScaffoldボディStack内
```dart
Scaffold(
  body: Stack(
    children: [
      YourMainContent(),
      const InAppWebViewInspectorWidget(), // ✅ 正しい配置
    ],
  ),
)
```

❌ **間違い**: MaterialAppビルダー内  
```dart
MaterialApp(
  builder: (context, child) => Stack(
    children: [
      child!,
      const InAppWebViewInspectorWidget(), // ❌ オーバーレイエラー発生
    ],
  ),
)
```

### よくある問題と解決策

1. **"No Overlay widget found"**: インスペクターウィジェットをMaterialApp.builderからScaffold Stack内に移動
2. **インスペクターが表示されない**: WebView登録後に`InAppWebViewInspector.enable()`が呼び出されていることを確認
3. **gitソースflutter_inappwebviewとの依存関係の競合**: dependency overrideを追加

アプリでflutter_inappwebviewをgitソースから使用している場合:
```yaml
dependencies:
  inappwebview_inspector: ^0.1.1
  flutter_inappwebview:
    git:
      url: https://github.com/pichillilorenzo/flutter_inappwebview.git
      ref: master
      path: flutter_inappwebview

dependency_overrides:
  flutter_inappwebview:
    git:
      url: https://github.com/pichillilorenzo/flutter_inappwebview.git
      ref: master
      path: flutter_inappwebview
```

## 📋 要件

- **Flutter**: >= 3.0.0
- **Dart**: >= 3.0.6  
- **flutter_inappwebview**: >= 6.0.0

## 🌐 プラットフォームサポート

| プラットフォーム | ステータス | 備考 |
|----------------|-----------|------|
| Android | ✅ 完全サポート | 全機能利用可能 |
| iOS | ✅ 完全サポート | 全機能利用可能 |

## 🤝 コントリビューション

このプロジェクトは、Claudeと**バイブコーディング**手法を使用した**AI支援開発**の力を実証しています。コントリビューションを歓迎します！

### コントリビュート方法

1. **フォーク** リポジトリをフォークしてください
2. **作成** 機能ブランチを作成してください（`git checkout -b feature/amazing-feature`）
3. **テスト** 変更を十分にテストしてください
4. **コミット** 変更をコミットしてください（`git commit -m 'Add amazing feature'`）
5. **プッシュ** ブランチにプッシュしてください（`git push origin feature/amazing-feature`）
6. **オープン** プルリクエストを開いてください

## 📄 ライセンス

このプロジェクトはMITライセンスの下にあります。詳細は[LICENSE](LICENSE)ファイルを参照してください。

## 🙏 謝辞

- **🤖 Claude AI**: このライブラリはClaudeを使用したAI-人間協力プログラミングにより開発されました
- **⚡ バイブコーディング**: AI支援開発手法の有効性を実証しました
- **💙 Flutterコミュニティ**: 素晴らしいFlutterフレームワークの提供に対して
- **🌐 flutter_inappwebview**: 優れたWebView基盤の提供に対して

## 📞 サポート・コミュニティ

- **🐛 イシュー**: [バグ・問題の報告](https://github.com/baccusf/inappwebview_inspector/issues)
- **💡 機能**: [新機能のリクエスト](https://github.com/baccusf/inappwebview_inspector/issues/new?template=feature_request.md)  
- **📖 ドキュメント**: 開発ガイドは包括的な[CLAUDE.md](CLAUDE.md)をご確認ください
- **💬 ディスカッション**: [コミュニティディスカッションに参加](https://github.com/baccusf/inappwebview_inspector/discussions)

## 🔗 関連リンク

- **📦 pub.dev**: [pub.devのパッケージ](https://pub.dev/packages/inappwebview_inspector)
- **🌐 リポジトリ**: [GitHubリポジトリ](https://github.com/baccusf/inappwebview_inspector)
- **📚 flutter_inappwebview**: [コアWebViewパッケージ](https://pub.dev/packages/flutter_inappwebview)
- **🤖 Claude**: [Claude AIについて詳しく](https://claude.ai)

---

**AI支援開発で楽しいデバッグを！** 🐛✨🤖