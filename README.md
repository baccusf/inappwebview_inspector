# InAppWebView Inspector 🔍

[![Pub Version](https://img.shields.io/pub/v/inappwebview_inspector)](https://pub.dev/packages/inappwebview_inspector)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A powerful WebView inspector and debugging tool for `flutter_inappwebview`. Provides real-time console monitoring, JavaScript execution, and script history management with a draggable overlay interface.

> 🤖 **Developed with Claude**: This Flutter library was developed using **Vibe coding** methodology in collaboration with Claude AI, showcasing the power of AI-assisted development and human-AI collaborative programming.

## 🌍 Multi-language Documentation

- **English** | [한국어 (Korean)](README_ko.md) | [日本語 (Japanese)](README_ja.md)

## ✨ Features

### 🚀 **Zero Setup Auto UI Injection** *(New!)*
- **No Manual Widget Placement**: Inspector UI automatically injects as overlay when `show()` is called
- **Smart Context Discovery**: Automatic BuildContext discovery via WidgetsBinding and NavigatorKey fallback  
- **Developer-Controlled**: User controls when auto-injection is enabled via debug mode initialization
- **Hot Reload Compatible**: Robust overlay system that works seamlessly with Flutter's hot reload
- **Performance Optimized**: Optional NavigatorKey integration for instant context access
- **Zero Configuration**: Just call `toggle()` and the UI appears - no Stack widgets or manual placement needed

### 🖥️ **Real-time Console Monitoring**
- **Live Console Output**: Monitor all JavaScript console messages (`log`, `warn`, `error`, `debug`) in real-time
- **Color-coded Messages**: Different colors for different log levels for easy identification
- **Timestamp Display**: Each message includes precise timestamp information
- **Multi-line Support**: Full support for long messages and multi-line output
- **Clean Interface**: Removed unnecessary labels for streamlined debugging experience

### 🚀 **Enhanced JavaScript Execution**
- **Interactive Console**: Execute JavaScript code directly in your WebView with intelligent result handling
- **Smart DOM Object Processing**: 
  - `document.querySelector("h1")` → Shows element details (tag, id, class, text content)
  - `document.querySelectorAll("p")` → Lists all matching elements with comprehensive information
  - `document.body.classList` → Automatically converts to readable array format
  - Functions and complex objects → Displays in developer-friendly format
- **Enhanced Error Handling**: Comprehensive error messages with helpful suggestions for common DOM operations
- **Unicode & Base64 Support**: Advanced script encoding options for complex scenarios

### 📚 **Intelligent Script History System**
- **Pre-loaded Scripts**: 15+ commonly used JavaScript snippets ready to use immediately
- **Frequency-based Sorting**: Most-used scripts automatically appear first
- **Memory-based Storage**: Fast, lightweight history management without file I/O
- **Smart Suggestions**: Context-aware script recommendations
- **Usage Tracking**: Automatically tracks and prioritizes frequently used scripts

### 🎯 **Multi-WebView Management**
- **Multiple WebView Support**: Handle unlimited WebViews in a single application
- **Easy Switching**: Quick dropdown to switch between registered WebViews
- **Individual Monitoring**: Each WebView maintains its own console and execution context
- **Automatic Registration**: Simple API to register and manage WebView instances

### 🌍 **Comprehensive Internationalization**
- **8 Languages Supported**: English, Korean, Japanese, Spanish, French, German, Chinese (Simplified), Portuguese
- **Auto-detection**: Automatic language detection from system locale
- **Easy Localization**: Simple API to set preferred language
- **Consistent UI**: All interface elements properly localized

### 🎨 **Advanced User Interface**
- **Draggable Overlay**: Move the inspector anywhere on screen with smooth drag interactions
- **Resizable Interface**: Switch between compact and maximized modes for different use cases
- **SafeArea Aware**: Automatically adjusts to device screen constraints and notches
- **Stack-based Architecture**: Stable popup system without overlay conflicts
- **Clean Design**: Minimal, developer-focused interface optimized for productivity

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  inappwebview_inspector: ^0.2.0
  flutter_inappwebview: ^6.1.5
```

Then run:

```bash
$ flutter pub get
```

## 🚀 Quick Start

### 1. Initialize the Inspector

Add this to your `main()` function:

```dart
import 'package:flutter/foundation.dart';
import 'package:inappwebview_inspector/inappwebview_inspector.dart';

void main() {
  // Zero setup initialization - show() will auto-inject UI
  if (kDebugMode) {
    InAppWebViewInspector.initializeDevelopment(
      enableScriptHistory: true,
      maxScriptHistoryCount: 25,
      localizations: InAppWebViewInspectorLocalizations.english, // Change as needed
      onScriptExecuted: (script, webViewId) {
        print('Executed: $script on $webViewId');
      },
      onConsoleLog: (log) {
        print('Console [${log.levelText}]: ${log.message}');
      },
    );
  }
  
  runApp(MyApp());
}
```

### 2. Add NavigatorKey for Optimal Performance (Recommended)

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebView Inspector Demo',
      // Add navigatorKey for optimal auto UI injection performance
      navigatorKey: InAppWebViewInspector.navigatorKey,
      home: MyWebViewPage(),
    );
  }
}
```

### 3. Simple WebView Setup - Zero Manual UI Placement

**✨ New: Zero Setup Auto UI Injection** - No need to manually add widgets to your UI!

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
          // Toggle button - UI will auto-inject when pressed!
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: InAppWebViewInspector.toggle,
            tooltip: 'Toggle Inspector\n(Zero Setup - UI Auto-Injected!)',
          ),
        ],
      ),
      // ✨ No Stack needed! Inspector UI auto-injects as overlay
      body: Column(
        children: [
          // Your main WebView - Inspector UI auto-injects when show() is called
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri('https://flutter.dev'),
              ),
              onWebViewCreated: (controller) {
                webViewController = controller;
                
                // Register WebView with inspector
                InAppWebViewInspector.registerWebView(
                  webViewId,
                  controller,
                  'https://flutter.dev',
                );
              },
              onLoadStop: (controller, url) {
                // Update URL in inspector when navigation occurs
                if (url != null) {
                  InAppWebViewInspector.updateWebViewUrl(
                    webViewId,
                    url.toString(),
                  );
                }
              },
              onConsoleMessage: (controller, consoleMessage) {
                // Forward console messages to inspector
                InAppWebViewInspector.addConsoleLog(
                  webViewId,
                  consoleMessage,
                );
              },
              initialSettings: InAppWebViewSettings(
                isInspectable: true, // Enable debugging
                javaScriptEnabled: true,
                domStorageEnabled: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Clean up when page is disposed
    InAppWebViewInspector.unregisterWebView(webViewId);
    super.dispose();
  }
}
```

### 4. Control Inspector Visibility

```dart
// Show/hide inspector - UI automatically injects as overlay!
InAppWebViewInspector.show();    // ✨ Auto-injects UI overlay
InAppWebViewInspector.hide();    // Removes overlay
InAppWebViewInspector.toggle();  // ✨ Toggle with auto-injection

// Enable/disable inspector
InAppWebViewInspector.enable();
InAppWebViewInspector.disable();

// Check status
bool isVisible = InAppWebViewInspector.isVisible;
bool isEnabled = InAppWebViewInspector.isEnabled;
```

## ⚙️ Configuration Options

### Development Mode (Recommended for Debug Builds)

```dart
// Zero setup - show() always auto-injects UI
if (kDebugMode) {
  InAppWebViewInspector.initializeDevelopment(
    enableScriptHistory: true,
    maxScriptHistoryCount: 25,
    maxConsoleLogCount: 500,
    localizations: InAppWebViewInspectorLocalizations.english,
    onScriptExecuted: (script, webViewId) {
      print('Script executed on $webViewId: $script');
    },
    onConsoleLog: (log) {
      print('Console [${log.levelText}]: ${log.message}');
    },
  );
}
```

### Production Mode (Minimal Impact)

```dart
// Only initialize in production if needed
if (!kReleaseMode) {
  InAppWebViewInspector.initializeProduction(
    maxConsoleLogCount: 50,
    enableAutoResultLogging: false,
    enableScriptHistory: false,
    localizations: InAppWebViewInspectorLocalizations.english,
  );
}
```

### Advanced Custom Configuration

```dart
// Advanced configuration with auto UI injection
if (kDebugMode) {
  InAppWebViewInspector.initializeWithConfig(
    InAppWebViewInspectorConfig(
      debugMode: true,
      maxConsoleLogCount: 1000,
      enableAutoResultLogging: true,
      enableUnicodeQuoteNormalization: true,
      enableBase64ScriptEncoding: true,
      enableScriptHistory: true,
      maxScriptHistoryCount: 30,
      localizations: InAppWebViewInspectorLocalizations.korean, // Multi-language support
      onScriptExecuted: (script, webViewId) {
        // Custom script execution callback
        analytics.logEvent('script_executed', {'webview_id': webViewId});
      },
      onConsoleLog: (log) {
        // Custom console logging
        if (log.level == ConsoleMessageLevel.ERROR) {
          crashlytics.recordError(log.message, null);
        }
      },
      onError: (error, webViewId) {
        // Error handling callback
        print('Inspector error in $webViewId: $error');
      },
    ),
  );
}
```

### Language Configuration

```dart
// Available localizations
InAppWebViewInspectorLocalizations.english
InAppWebViewInspectorLocalizations.korean
InAppWebViewInspectorLocalizations.japanese
InAppWebViewInspectorLocalizations.spanish
InAppWebViewInspectorLocalizations.french
InAppWebViewInspectorLocalizations.german
InAppWebViewInspectorLocalizations.chineseSimplified
InAppWebViewInspectorLocalizations.portuguese

// Auto-detect from system locale
final localization = InAppWebViewInspectorLocalizations.getByLanguageCode(
  Localizations.localeOf(context).languageCode
);
```

## 🎯 Advanced Usage Examples

### Multiple WebViews Management

```dart
class MultiWebViewExample extends StatefulWidget {
  @override
  _MultiWebViewExampleState createState() => _MultiWebViewExampleState();
}

class _MultiWebViewExampleState extends State<MultiWebViewExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multiple WebViews'),
        actions: [
          // Single toggle button for all WebViews - UI auto-injects!
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: InAppWebViewInspector.toggle,
            tooltip: 'Toggle Inspector\n(Zero Setup Auto UI)',
          ),
        ],
      ),
      // ✨ No Stack needed! Inspector UI auto-injects as overlay
      body: Column(
        children: [
          // First WebView
          Expanded(
            child: InAppWebView(
              onWebViewCreated: (controller) {
                InAppWebViewInspector.registerWebView(
                  'webview_1',
                  controller,
                  'https://flutter.dev',
                );
              },
              onConsoleMessage: (controller, consoleMessage) {
                InAppWebViewInspector.addConsoleLog('webview_1', consoleMessage);
              },
              initialSettings: InAppWebViewSettings(
                isInspectable: true,
                javaScriptEnabled: true,
              ),
            ),
          ),
          // Second WebView  
          Expanded(
            child: InAppWebView(
              onWebViewCreated: (controller) {
                InAppWebViewInspector.registerWebView(
                  'webview_2', 
                  controller,
                  'https://dart.dev',
                );
              },
              onConsoleMessage: (controller, consoleMessage) {
                InAppWebViewInspector.addConsoleLog('webview_2', consoleMessage);
              },
              initialSettings: InAppWebViewSettings(
                isInspectable: true,
                javaScriptEnabled: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Custom Console Messages

```dart
// Add custom messages from Flutter
InAppWebViewInspector.instance.addCustomConsoleLog(
  InAppWebViewInspectorConsoleMessage(
    webViewId: 'main',
    level: ConsoleMessageLevel.WARNING,
    message: 'Custom warning from Flutter side',
    source: null, // Clean interface without source labels
    line: null,
    timestamp: DateTime.now(),
  ),
);

// Add development debug messages
InAppWebViewInspector.instance.addCustomConsoleLog(
  InAppWebViewInspectorConsoleMessage(
    webViewId: 'main',
    level: ConsoleMessageLevel.LOG,
    message: 'Flutter lifecycle: App resumed',
    source: null,
    line: null,
    timestamp: DateTime.now(),
  ),
);
```

### Programmatic Script Execution

```dart
// Execute custom scripts programmatically
void executeCustomScripts() {
  final inspector = InAppWebViewInspector.instance;
  
  // Simple value retrieval
  inspector.executeScript('document.title');
  
  // Complex DOM operations  
  inspector.executeScript('''
    const links = document.querySelectorAll('a');
    Array.from(links).map(link => ({
      text: link.textContent?.trim(),
      href: link.href,
      className: link.className
    }));
  ''');
  
  // Error handling example
  inspector.executeScript('''
    try {
      const result = performComplexOperation();
      console.log('Operation successful:', result);
      return result;
    } catch (error) {
      console.error('Operation failed:', error.message);
      return { error: error.message, stack: error.stack };
    }
  ''');
}
```

## 🛠️ Pre-loaded Utility Scripts

The inspector comes with 15+ ready-to-use JavaScript snippets:

### Page Information
- `document.title` - Get current page title
- `window.location.href` - Get current URL
- `document.readyState` - Check page load state
- `document.getElementsByTagName("*").length` - Count all elements

### DOM Manipulation  
- `document.querySelector("selector")` - Find single element with details
- `document.querySelectorAll("selector")` - Find all matching elements
- `document.body.innerHTML` - Get page HTML content
- `document.cookie` - View all cookies

### Browser & Performance
- `navigator.userAgent` - Get browser information
- `window.innerWidth + "x" + window.innerHeight` - Get viewport size
- `performance.now()` - High-precision timing
- `Object.keys(window)` - List global variables

### Storage Access
- `localStorage.getItem("key")` - Access local storage
- `sessionStorage.getItem("key")` - Access session storage

### Development Utilities
- `console.log("Hello World");` - Basic console logging

## 📸 Screenshots

### iOS Inspector Interface
<img src="screenshots/ios_inspector_demo.png" width="300" alt="iOS WebView Inspector Demo">

*The inspector running on iOS showing the draggable overlay interface*

### Android Inspector Interface  
<img src="screenshots/android_inspector_demo.png" width="300" alt="Android WebView Inspector Demo">

*The inspector running on Android with the same powerful debugging features*

### Key Interface Features Shown:
- **🖱️ Draggable Overlay**: Move the inspector anywhere on screen
- **📱 Responsive Design**: Adapts to different screen sizes and orientations  
- **🎯 WebView Selector**: Dropdown to switch between multiple WebViews
- **⌨️ Interactive Console**: JavaScript input field with history dropdown
- **📋 Real-time Logs**: Color-coded console output with timestamps
- **🔄 Resizable Interface**: Toggle between compact and maximized modes

## 🔄 Migration Guide: v0.1.x → v0.2.0

### ✨ What's New in v0.2.0

**Major Feature: Zero Setup Auto UI Injection**
- No more manual widget placement required
- Automatic context discovery and overlay injection
- Simplified integration with just `toggle()` calls

### 🚨 Breaking Changes

#### 1. **Widget Placement No Longer Required** *(Simplified - Not Breaking)*
**Before (v0.1.x)**: Manual Stack placement required
```dart
// ❌ Old way - Still works but not needed
Scaffold(
  body: Stack(
    children: [
      YourContent(),
      const InAppWebViewInspectorWidget(), // Manual placement
    ],
  ),
)
```

**After (v0.2.0)**: Zero setup auto-injection *(Recommended)*
```dart
// ✅ New way - UI auto-injects as overlay
Scaffold(
  body: YourContent(), // No Stack needed!
)

// Just call toggle - UI appears automatically
InAppWebViewInspector.toggle();
```

#### 2. **NavigatorKey Integration** *(New Recommendation)*
For optimal performance, add NavigatorKey to your MaterialApp:

```dart
// ✅ Recommended for v0.2.0
MaterialApp(
  navigatorKey: InAppWebViewInspector.navigatorKey, // New
  home: YourHomePage(),
)
```

### 📋 Migration Steps

#### Step 1: Update Dependencies
```yaml
dependencies:
  inappwebview_inspector: ^0.2.0  # Updated
  flutter_inappwebview: ^6.1.5
```

#### Step 2: Add NavigatorKey (Recommended)
```dart
MaterialApp(
  navigatorKey: InAppWebViewInspector.navigatorKey, // Add this line
  home: YourHomePage(),
)
```

#### Step 3: Simplify UI (Optional)
You can now remove manual Stack placement:
```dart
// Before: Required Stack
Scaffold(
  body: Stack(
    children: [
      YourContent(),
      const InAppWebViewInspectorWidget(),
    ],
  ),
)

// After: Simple layout - Inspector auto-injects
Scaffold(
  body: YourContent(),
)
```

#### Step 4: Test Auto-Injection
```dart
// Inspector UI will auto-inject when you call:
InAppWebViewInspector.show();
InAppWebViewInspector.toggle();
```

### ⚡ Performance Improvements

- **Faster Context Discovery**: NavigatorKey provides instant context access
- **Reduced Widget Tree**: No manual Stack widgets needed
- **Hot Reload Friendly**: Robust overlay system works seamlessly with Flutter's hot reload

### 🔧 Troubleshooting Migration Issues

1. **Inspector not appearing**: Add `navigatorKey: InAppWebViewInspector.navigatorKey` to MaterialApp
2. **"No Overlay widget found"**: Ensure you're calling `toggle()` after initialization
3. **Layout issues**: Remove manual Stack placement - auto-injection handles positioning

### 🆕 New Features in v0.2.0

- **Automatic UI Injection**: Zero setup overlay system
- **Smart Context Discovery**: Automatic BuildContext discovery
- **NavigatorKey Integration**: Optional performance optimization
- **Enhanced Error Recovery**: Better fallback mechanisms
- **Hot Reload Compatibility**: Improved development experience

## ⚠️ Important Implementation Notes

### ✨ Zero Setup Auto UI Injection

**New Simplified Approach**: No manual widget placement required!

✅ **New Zero Setup Method**: Auto UI injection (Recommended)
```dart
// 1. Add NavigatorKey for optimal performance
MaterialApp(
  navigatorKey: InAppWebViewInspector.navigatorKey, // ✅ Optimal setup
  home: MyWebViewPage(),
)

// 2. Simple UI with no Stack needed
Scaffold(
  body: Column(  // ✅ Simple layout
    children: [
      Expanded(
        child: InAppWebView(
          // Register WebView and inspector auto-injects UI
          onWebViewCreated: (controller) {
            InAppWebViewInspector.registerWebView('main', controller, url);
          },
        ),
      ),
    ],
  ),
)

// 3. Toggle inspector - UI auto-appears as overlay!
InAppWebViewInspector.toggle(); // ✅ Zero manual UI work
```

### Legacy Manual Widget Placement (Still Supported)

For advanced use cases, you can still manually place the widget:

```dart
Scaffold(
  body: Stack(
    children: [
      YourMainContent(),
      const InAppWebViewInspectorWidget(), // Manual placement
    ],
  ),
)
```

### Common Issues & Solutions

1. **Inspector not appearing**: Ensure NavigatorKey is added to MaterialApp for optimal context discovery
2. **Auto UI injection fails**: Check that you're in debug mode and inspector is properly initialized
3. **"No Overlay widget found"**: Add `navigatorKey: InAppWebViewInspector.navigatorKey` to your MaterialApp
4. **Dependency conflict with git-sourced flutter_inappwebview**: Add dependency override

If your app uses flutter_inappwebview from git source:
```yaml
dependencies:
  inappwebview_inspector: ^0.2.0
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

### Development vs Production

**Development Build with Auto UI Injection:**
```dart
if (kDebugMode) {
  InAppWebViewInspector.initializeDevelopment(
    enableScriptHistory: true,
    maxConsoleLogCount: 500,
  );
}
```

**Production Build (Optional):**
```dart
if (!kReleaseMode) {
  InAppWebViewInspector.initializeProduction(
    maxConsoleLogCount: 50,
    enableScriptHistory: false,
  );
}
```

## 📱 Example App

The [example app](example/) demonstrates:

- ✅ Complete WebView integration with inspector
- ✅ Multi-language support demonstration  
- ✅ Pre-loaded script usage
- ✅ Enhanced DOM object handling
- ✅ Multiple WebView management
- ✅ Custom script execution examples

Run the example:

```bash
cd example && flutter run
```

## 📋 Requirements

- **Flutter**: >= 3.24.0
- **Dart**: >= 3.5.0  
- **flutter_inappwebview**: >= 6.1.5

## 🌐 Platform Support

| Platform | Status | Notes |
|----------|---------|--------|
| Android | ✅ Full Support | All features available |
| iOS | ✅ Full Support | All features available |

## 🤝 Contributing

This project demonstrates the power of **AI-assisted development** using Claude and **Vibe coding** methodology. Contributions are welcome!

### How to Contribute

1. **Fork** the repository
2. **Create** your feature branch (`git checkout -b feature/amazing-feature`)
3. **Test** your changes thoroughly 
4. **Commit** your changes (`git commit -m 'Add amazing feature'`)
5. **Push** to the branch (`git push origin feature/amazing-feature`)
6. **Open** a Pull Request

### Development Setup

```bash
# Clone the repository
git clone https://github.com/baccusf/inappwebview_inspector.git
cd inappwebview_inspector

# Install dependencies  
flutter pub get

# Run tests
flutter test

# Run example
cd example && flutter run
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **🤖 Claude AI**: This library was developed through AI-human collaborative programming using Claude
- **⚡ Vibe Coding**: Demonstrated the effectiveness of AI-assisted development methodology  
- **💙 Flutter Community**: For providing the amazing Flutter framework
- **🌐 flutter_inappwebview**: For the excellent WebView foundation

## 📞 Support & Community

- **🐛 Issues**: [Report bugs and issues](https://github.com/baccusf/inappwebview_inspector/issues)
- **💡 Features**: [Request new features](https://github.com/baccusf/inappwebview_inspector/issues/new?template=feature_request.md)  
- **📖 Documentation**: Check the comprehensive [CLAUDE.md](CLAUDE.md) for development guidance
- **💬 Discussions**: [Join community discussions](https://github.com/baccusf/inappwebview_inspector/discussions)

## 🔗 Related Links

- **📦 pub.dev**: [Package on pub.dev](https://pub.dev/packages/inappwebview_inspector)
- **🌐 Repository**: [GitHub Repository](https://github.com/baccusf/inappwebview_inspector)
- **📚 flutter_inappwebview**: [Core WebView package](https://pub.dev/packages/flutter_inappwebview)
- **🤖 Claude**: [Learn more about Claude AI](https://claude.ai)

---

**Happy debugging with AI-assisted development!** 🐛✨🤖