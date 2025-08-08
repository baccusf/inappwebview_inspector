# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter package called `inappwebview_inspector` (version 0.1.0) - a powerful WebView debugging tool for `flutter_inappwebview`. It provides real-time console monitoring, JavaScript execution, and script history management with a draggable overlay interface.

## Common Development Commands

### Package Management
```bash
# Install dependencies
fvm flutter pub get

# Install dependencies for example app
cd example && fvm flutter pub get

# Upgrade dependencies
fvm flutter pub upgrade
```

### Testing & Analysis
```bash
# Run static analysis
fvm flutter analyze

# Run tests
fvm flutter test

# Run example app
cd example && fvm flutter run
```

### Building
```bash
# Build example app for different platforms
cd example
fvm flutter build apk                              # Android
fvm flutter build ios --simulator --no-codesign   # iOS Simulator
fvm flutter build web                              # Web
fvm flutter build macos                            # macOS
fvm flutter build windows                          # Windows
fvm flutter build linux                            # Linux
```

### Package Development
```bash
# Check package formatting
dart format --set-exit-if-changed .

# Validate package
fvm flutter packages pub publish --dry-run
```

## Architecture Overview

The package follows a clean architecture pattern with clear separation of concerns:

### Core Architecture
- **Interface-based design**: `InAppWebViewInspectorInterface` defines the contract
- **Factory pattern**: `InAppWebViewInspectorFactory` manages instance creation and configuration
- **Service locator**: `InAppWebViewInspectorService` provides global access to instances
- **Implementation**: `InAppWebViewInspectorImpl` contains the core reactive logic using Streams

### Package Structure
```
lib/
├── src/
│   ├── core/                    # Core inspection logic
│   │   ├── inappwebview_inspector.dart           # Main convenience class
│   │   ├── inappwebview_inspector_interface.dart # Interface definitions
│   │   ├── inappwebview_inspector_impl.dart      # Core implementation with enhanced script execution
│   │   └── inappwebview_inspector_factory.dart   # Factory & service locator
│   ├── services/                # Business logic services
│   │   ├── inappwebview_inspector_script_history.dart         # History data model
│   │   └── inappwebview_inspector_script_history_manager.dart # Memory-based history persistence
│   ├── ui/                     # UI components (완전 구현됨)
│   │   ├── inappwebview_inspector_widget.dart              # Main UI widget with enhanced console display
│   │   ├── inappwebview_inspector_focus_controller.dart    # Focus management
│   │   └── inappwebview_inspector_script_history_controller.dart # History state controller
│   └── utils/                  # Utilities and constants
│       ├── inappwebview_inspector_constants.dart        # UI and system constants
│       ├── inappwebview_inspector_localizations.dart    # Multi-language support
│       └── inappwebview_inspector_script_utils.dart     # Script execution utilities for DOM handling
└── inappwebview_inspector.dart  # Public API exports
```

### Data Flow
1. **Registration**: WebViews register through `InAppWebViewInspector.registerWebView()`
2. **Console Monitoring**: Console messages flow through `addConsoleLog()` to Stream-based state
3. **Script Execution**: JavaScript execution via `executeScript()` with enhanced DOM object handling
4. **History Management**: Script history managed in memory with frequency tracking and pre-loaded scripts

## Key Components

### InAppWebViewInspector (Main API)
The primary interface for package users:
- **Initialization**: `initializeDevelopment()`, `initializeProduction()`, `initializeWithConfig()`
- **WebView Management**: `registerWebView()`, `unregisterWebView()`, `setWebViewVisibility()`
- **Inspector Control**: `show()`, `hide()`, `toggle()`, `enable()`, `disable()`

### InAppWebViewInspectorConfig
Configuration class supporting:
- Console log limits (`maxConsoleLogCount`)
- Script history settings (`enableScriptHistory`, `maxScriptHistoryCount`)
- Callback functions (`onScriptExecuted`, `onConsoleLog`, `onError`)
- Feature flags (Unicode normalization, Base64 encoding)
- Localization settings (`localizations`)

### InAppWebViewInspectorConsoleMessage
Console message data model with:
- Message level color coding (ERROR: red, WARN: orange, LOG: green, DEBUG: blue)
- Timestamp and source information (now optional for cleaner UI)
- WebView association

### Script History System
- **Model**: `InAppWebViewInspectorScriptHistory` with usage frequency tracking
- **Manager**: `InAppWebViewInspectorScriptHistoryManager` using memory-based storage
- **Sorting**: Smart frequency-based ordering (most used → most recent)
- **Pre-loaded Scripts**: 15+ commonly used JavaScript snippets for immediate use

## Development Workflow

### Adding New Features
1. Define interface methods in `inappwebview_inspector_interface.dart`
2. Implement in `inappwebview_inspector_impl.dart` using reactive Streams
3. Add convenience methods to `inappwebview_inspector.dart`
4. Update example app in `example/lib/main.dart`
5. Add tests in `test/` directory

### UI Components
- **InAppWebViewInspectorWidget**: Fully-featured draggable UI widget
- **Features**: 
  - Draggable overlay interface with SafeArea constraints
  - Size modes (compact/maximized)
  - WebView selector dropdown
  - JavaScript console input/execution
  - Script history system with usage frequency tracking
  - Real-time console log monitoring
  - Multi-language support (8 languages)
- **Stack-based popups**: Safe Stack-based popup implementation instead of overlay system

### Testing Strategy
- Unit tests for core logic (`inappwebview_inspector_impl.dart`)
- Widget tests for UI components (`inappwebview_inspector_widget.dart`)
- Integration tests with actual WebView instances
- Use the existing test structure in `test/inappwebview_inspector_test.dart`

## Package Dependencies

### Runtime Dependencies
- `flutter`: Core Flutter framework
- `flutter_inappwebview: ^6.0.0`: WebView implementation
- `shared_preferences: ^2.0.0`: Local data persistence

### Development Dependencies
- `flutter_test`: Testing framework
- `flutter_lints: ^5.0.0`: Dart/Flutter linting rules

## Integration Patterns

### Basic Integration with UI
```dart
// Initialize in main()
InAppWebViewInspector.initializeDevelopment();

// Add UI widget to your app (inside Scaffold body)
Scaffold(
  body: Stack(
    children: [
      Column(
        children: [
          // Your existing UI
          Expanded(
            child: InAppWebView(
              onWebViewCreated: (controller) {
                InAppWebViewInspector.registerWebView('main', controller, url);
                InAppWebViewInspector.setWebViewVisibility('main', true);
                InAppWebViewInspector.enable();
              },
              onConsoleMessage: (controller, consoleMessage) {
                InAppWebViewInspector.addConsoleLog('main', consoleMessage);
              },
              initialSettings: InAppWebViewSettings(
                isInspectable: true,
                javaScriptEnabled: true,
              ),
            ),
          ),
        ],
      ),
      // Add WebView Inspector Widget
      const InAppWebViewInspectorWidget(),
    ],
  ),
)
```

### Multi-WebView Support
```dart
// Register multiple WebViews
InAppWebViewInspector.registerWebView('webview1', controller1, url1);
InAppWebViewInspector.registerWebView('webview2', controller2, url2);

// Switch between them
InAppWebViewInspector.instance.setActiveWebView('webview2');
```

### Custom Configuration
```dart
InAppWebViewInspector.initializeWithConfig(
  InAppWebViewInspectorConfig(
    maxConsoleLogCount: 1000,
    enableScriptHistory: true,
    localizations: InAppWebViewInspectorLocalizations.korean,
    onScriptExecuted: (script, webViewId) => logExecution(script),
    onError: (error, webViewId) => handleError(error),
  ),
);
```

## Platform Support

The package supports Android and iOS platforms:
- ✅ Android - Full support with all features
- ✅ iOS - Full support with all features

## Development Environment

- **Flutter**: >= 3.0.0
- **Dart**: >= 3.0.6
- **IDE**: VS Code or Android Studio with Flutter extensions
- **Testing**: Use `flutter test` for unit tests, `cd example && flutter run` for integration testing

## Recent Development History



### Package Development Phase (2025-08-08)

**Core Features Implemented:**
1. **Enhanced Script Execution System**:
   - **DOM Object Handling**: Added `InAppWebViewInspectorScriptUtils` for safe serialization of DOM objects
   - **Smart Script Wrapping**: Automatic detection and conversion of DOM elements to readable format
   - **Enhanced Result Display**: Better formatting for NodeList, HTMLElement, functions, etc.

2. **Console Display Improvements**:
   - **Multi-line Support**: Added `maxLines: null` and `softWrap: true` for proper text wrapping
   - **Complete Result Display**: Full results without truncation
   - **Clean UI**: Removed unnecessary labels for streamlined console output

3. **Script Execution Features**:
   - ✅ `document.querySelector("selector")` → Shows element info with tag, id, class, textContent
   - ✅ `document.querySelectorAll("selector")` → Shows all elements in comma-separated format
   - ✅ `document.body.classList` → Converts to array format
   - ✅ DOM element serialization with proper error handling
   - ✅ Enhanced error messages with suggestions for unsupported types

## Naming Convention and Prefixes

This package follows a consistent naming convention with the `InAppWebView` prefix to avoid conflicts and maintain clarity:

### Class Naming Pattern
```dart
// Main classes
InAppWebViewInspector                    // Main API class
InAppWebViewInspectorConfig              // Configuration class
InAppWebViewInspectorInterface           // Interface definition
InAppWebViewInspectorImpl                // Core implementation

// UI components
InAppWebViewInspectorWidget              // Main UI widget
InAppWebViewInspectorFocusController     // Focus management
InAppWebViewInspectorScriptHistoryController // History controller

// Services and utilities
InAppWebViewInspectorScriptHistory       // History data model
InAppWebViewInspectorScriptHistoryManager // History manager
InAppWebViewInspectorScriptUtils         // Script utilities
InAppWebViewInspectorConstants           // Constants
InAppWebViewInspectorLocalizations       // Localization
InAppWebViewInspectorConsoleMessage      // Console message model
```

### File Naming Pattern
All files follow the `inappwebview_inspector_*` pattern:
```
inappwebview_inspector.dart                    # Main export
inappwebview_inspector_widget.dart             # UI widget
inappwebview_inspector_impl.dart               # Implementation
inappwebview_inspector_interface.dart          # Interface
inappwebview_inspector_factory.dart            # Factory
inappwebview_inspector_script_history.dart     # History model
inappwebview_inspector_script_history_manager.dart # History manager
inappwebview_inspector_script_history_controller.dart # History controller
inappwebview_inspector_focus_controller.dart   # Focus controller
inappwebview_inspector_script_utils.dart       # Script utilities
inappwebview_inspector_constants.dart          # Constants
inappwebview_inspector_localizations.dart      # Localization
```

### Benefits of Consistent Naming
- **Conflict Avoidance**: Prevents naming conflicts with other packages
- **Clear Origin**: Easy to identify which classes belong to this package
- **IDE Support**: Better autocompletion and navigation
- **Maintainability**: Easier to manage and refactor
- **Professional Standard**: Follows Flutter/Dart naming conventions

### Future Improvements
- Performance optimization: Console log virtualization for handling large volumes
- Dark mode support
- Keyboard shortcuts support
- Additional script templates

## Critical Implementation Notes

### Widget Placement
**⚠️ Important**: `InAppWebViewInspectorWidget` must be placed in the correct context:
- ✅ **Recommended**: Inside Scaffold body Stack
- ❌ **Not Recommended**: Direct use in MaterialApp.builder (no Overlay context)

```dart
// ✅ Correct usage
Scaffold(
  body: Stack(
    children: [
      // Your main UI
      Column(...),
      // Inspector widget
      const InAppWebViewInspectorWidget(),
    ],
  ),
)

// ❌ Incorrect usage - Will cause overlay errors
MaterialApp(
  builder: (context, child) => Stack(
    children: [child!, const InAppWebViewInspectorWidget()],
  ),
)
```

### Known Issues & Solutions
1. **"No Overlay widget found"**: Place widget inside Scaffold Stack instead of MaterialApp.builder
2. **"RenderFlex overflowed"**: Automatic boundary checking resolves this on screen size changes
3. **Build errors**: Use `fvm flutter` commands and ensure `isInspectable: true` setting

### Development Commands (Important)
```bash
# Must use fvm for consistency
fvm flutter pub get
fvm flutter analyze
fvm flutter test
fvm flutter build ios --simulator
fvm flutter run

# Do not use regular flutter commands
# flutter pub get  # ❌ 
```