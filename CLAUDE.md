# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Communication Guidelines

**Language Usage Policy:**
- **Korean (한국어)**: Use for all interactive communication, explanations, and discussions during development work
- **English**: Use for all documentation, Git commits, issues, pull requests, and code comments

This ensures clear communication during development while maintaining professional English documentation for the global developer community.

## Project Overview

This is a Flutter package called `inappwebview_inspector` - a powerful WebView debugging tool for `flutter_inappwebview`. It provides real-time console monitoring, JavaScript execution, script history management, and a draggable inspector interface with minimal mode support.

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
│   ├── ui/                     # UI components
│   │   ├── inappwebview_inspector_widget.dart              # Main UI widget with minimal mode support
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

### Standard Development Process

This project follows a structured development workflow to ensure quality and consistency:

#### 🚀 New Feature Development Workflow

**Phase 1: Planning & Issue Creation**
1. **Create Implementation Plan**
   - Analyze requirements and define feature scope
   - Design technical architecture and approach
   - Identify affected components and dependencies
   - Plan testing strategy and quality gates

2. **GitHub Issue Creation**
   - Use Feature Request template (`.github/ISSUE_TEMPLATE/feature_request.md`)
   - Include comprehensive feature specification
   - Set appropriate milestone for target release
   - Add relevant labels (enhancement, priority level)
   - Reference any related issues or dependencies

**Phase 2: Development & Implementation**
3. **Git Flow Branch Management**
   - Create feature branch from `develop`: `feature/feature-name`
   - Follow git flow conventions for branch naming
   - Implement changes following existing code patterns

4. **Code Implementation**
   - Define interface methods in `inappwebview_inspector_interface.dart`
   - Implement in `inappwebview_inspector_impl.dart` using reactive Streams
   - Add convenience methods to `inappwebview_inspector.dart`
   - Update example app in `example/lib/main.dart`
   - Add comprehensive tests in `test/` directory

5. **Development Commits**
   - Make regular commits with clear, descriptive messages
   - Follow conventional commit format (feat:, fix:, refactor:, etc.)
   - Include co-authored attribution for Claude Code assistance

**Phase 3: Quality Assurance & PR**
6. **Pre-PR Quality Checks**
   - Run `fvm flutter analyze` (must pass with zero warnings)
   - Run `fvm flutter test` (all tests must pass)
   - Verify pub.dev package validation passes
   - Test functionality in example app across platforms

7. **Pull Request Creation**
   - Use standardized PR template (`.github/PULL_REQUEST_TEMPLATE.md`)
   - Complete all applicable checklist items
   - Reference milestone from original issue
   - Link to related issues using "Closes #123" format
   - Include comprehensive testing results

**Phase 4: Review & Completion**
8. **Post-Merge Cleanup**
   - Update original issue with implementation details
   - Mark issue as completed and close
   - Update milestone progress if applicable
   - Clean up feature branch after successful merge

#### 🐛 Bug Fix Workflow

**Simplified Process for Bug Fixes:**
1. **Issue Creation**: Use Bug Report template with reproduction steps
2. **Branch Creation**: Create `fix/bug-description` branch from `develop`
3. **Implementation**: Fix issue with appropriate tests
4. **PR Creation**: Use PR template with focus on testing and regression prevention
5. **Completion**: Close issue after successful merge

#### 📋 Workflow Checklist

**Before Starting Development:**
- [ ] Feature plan created and documented
- [ ] GitHub issue created with milestone
- [ ] Feature branch created from develop
- [ ] Implementation approach confirmed

**Before Creating PR:**
- [ ] All code changes committed
- [ ] `flutter analyze` passes with zero warnings
- [ ] All tests pass (`flutter test`)
- [ ] Example app tested and updated
- [ ] pub.dev validation confirmed

**Before Closing Issue:**
- [ ] PR merged successfully
- [ ] Issue updated with final implementation notes
- [ ] Milestone progress updated
- [ ] Documentation updated if needed

This structured approach ensures consistent quality, proper documentation, and maintainable development practices.

### UI Components
- **InAppWebViewInspectorWidget**: Fully-featured draggable UI widget
- **Features**: 
  - Draggable overlay interface with SafeArea constraints
  - Size modes (minimal/medium/maximized) with one-click toggle
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

## Key Features

### Inspector Widget Capabilities
- **Multi-Size Modes**: Minimal (60x40px), Medium (responsive), Maximized (full screen)
- **Smart State Management**: Remembers previous size mode for restoration
- **Status Indicators**: Visual feedback for WebView activity and console errors
- **Drag & Drop**: Fully draggable interface with boundary constraints
- **Script History**: Frequency-based history with pre-loaded common scripts

### Enhanced Script Execution
- **DOM Object Handling**: Safe serialization of DOM objects and elements
- **Smart Result Display**: Proper formatting for NodeList, HTMLElement, functions
- **Multi-line Console**: Complete result display without truncation
- **Error Handling**: Enhanced error messages with helpful suggestions

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

### Future Roadmap
- Performance optimization: Console log virtualization for large volumes
- Dark mode support and theme customization
- Keyboard shortcuts and accessibility improvements
- Additional script templates and developer tools integration

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
fvm flutter analyze   # Must pass with no linting errors
fvm flutter test
fvm flutter build ios --simulator
fvm flutter run

# Do not use regular flutter commands
# flutter pub get  # ❌ 
```

## Code Quality Standards

### Lint Rule Compliance
This package follows strict linting rules for pub.dev compliance and code quality:

1. **Required Curly Braces**: All if statements must include curly braces, even for single-line statements
   ```dart
   // ✅ Correct - with curly braces
   if (condition) {
     doSomething();
   }
   
   // ❌ Incorrect - missing curly braces
   if (condition) doSomething();
   ```

2. **Analysis Requirements**: 
   - `fvm flutter analyze` must pass with zero warnings/errors
   - All pub.dev package validation checks must pass
   - Consistent code formatting across all files

3. **Quality Checklist**:
   - ✅ No lint warnings or errors
   - ✅ Consistent code style and formatting
   - ✅ All if statements have curly braces
   - ✅ Proper documentation and comments
   - ✅ Pass pub.dev package validation

## GitHub Issue and PR Templates

This project uses standardized templates to ensure consistent documentation and streamline the development workflow:

### Issue Templates

**Feature Request Template** (`.github/ISSUE_TEMPLATE/feature_request.md`)
- Structured format for proposing new features
- Includes sections for requirements, implementation approach, user flow, and success criteria
- Ensures comprehensive feature documentation before development

**Bug Report Template** (`.github/ISSUE_TEMPLATE/bug_report.md`)
- Systematic bug reporting with reproduction steps
- Environment details and error information
- Impact assessment and potential workarounds

### Pull Request Template

**Standardized PR Template** (`.github/PULL_REQUEST_TEMPLATE.md`)
- Consistent structure for all pull requests
- Comprehensive testing and quality assurance checklists
- Clear categorization of changes (feature/fix/enhancement)
- Links to related issues and includes reviewer guidelines

### Template Usage Guidelines

**For Issues:**
1. **Feature Requests**: Use the feature request template for all new functionality
2. **Bug Reports**: Use the bug report template for defects and issues
3. **Clear Titles**: Use conventional commit format (feat:, fix:, docs:, etc.)
4. **Complete Information**: Fill out all relevant sections thoroughly

**For Pull Requests:**
1. **Comprehensive Testing**: Complete all applicable test checklist items
2. **Quality Assurance**: Verify all QA requirements before submitting
3. **Clear Descriptions**: Provide detailed descriptions of changes and impact
4. **Link Issues**: Always link to related issues using "Closes #123" format

**Template Compliance:**
- All issues and PRs should follow the provided templates
- Templates ensure consistent documentation and make reviews more efficient
- Missing information in templates may result in requests for additional details