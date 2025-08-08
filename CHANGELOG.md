# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-08-08

### 🎉 Initial Release
- **Developed with Claude AI**: This library was created using **Vibe coding** methodology in collaboration with Claude AI, showcasing AI-assisted development capabilities.

### ✨ Features Added
- **Real-time Console Monitoring**: Live monitoring of JavaScript console messages (`log`, `warn`, `error`, `debug`) with color-coded display and timestamps
- **Enhanced JavaScript Execution**: Interactive console with intelligent DOM object handling
  - Smart serialization for `document.querySelector()` and `document.querySelectorAll()`
  - Automatic conversion of DOM objects to readable format
  - Enhanced error handling with helpful suggestions
- **Intelligent Script History System**: 
  - 15+ pre-loaded commonly used JavaScript snippets
  - Frequency-based sorting with usage tracking
  - Memory-based storage for fast performance
- **Multi-WebView Support**: Handle multiple WebViews with easy switching and individual monitoring
- **Comprehensive Internationalization**: Support for 8 languages (English, Korean, Japanese, Spanish, French, German, Chinese Simplified, Portuguese)
- **Advanced UI Interface**: 
  - Draggable overlay with SafeArea constraints
  - Resizable interface (compact/maximized modes)
  - Stack-based popup system for stability
  - Clean design without unnecessary labels

### 🛠️ Technical Improvements
- **Script Utilities**: `InAppWebViewInspectorScriptUtils` for safe DOM object serialization
- **Enhanced Error Handling**: Comprehensive error messages with suggestions for common DOM operations
- **Memory-based History**: Fast, lightweight script history management without file I/O
- **Clean Console Output**: Removed `User Input:` and `Script Result:` labels for streamlined debugging

### 🌐 Platform Support
- **Android**: ✅ Full support with all features
- **iOS**: ✅ Full support with all features

### 📚 Documentation
- **Multi-language README**: Complete documentation in English, Korean, and Japanese
- **Comprehensive Examples**: Complete integration examples and advanced usage scenarios
- **Developer Guide**: Detailed CLAUDE.md for development guidance

### 🔧 Configuration Options
- **Development Mode**: Enhanced features with full script history and debugging capabilities
- **Production Mode**: Minimal impact mode with reduced features
- **Custom Configuration**: Flexible configuration with callbacks and feature toggles

### ⚠️ Important Notes
- Widget must be placed inside Scaffold body Stack (not MaterialApp.builder)
- Requires `flutter_inappwebview: ^6.0.0`
- Flutter >= 3.0.0 and Dart >= 3.0.6 required
