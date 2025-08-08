/// Constants used in WebView Inspector
class InAppWebViewInspectorConstants {
  // Disable constructor
  const InAppWebViewInspectorConstants._();

  // === UI Size Constants ===

  /// Default widget width
  static const double defaultWidgetWidth = 350.0;

  /// Default widget height
  static const double defaultWidgetHeight = 400.0;

  /// Widget screen ratio (3/5 of screen width)
  static const double widgetScreenRatio = 3.0 / 5.0;

  /// Header height
  static const double headerHeight = 50.0;

  /// WebView selector area height (estimated)
  static const double webViewSelectorHeight = 64.0;

  /// Default JavaScript input field height
  static const double defaultInputFieldHeight = 32.0;

  /// Maximum JavaScript input field height
  static const double maxInputFieldHeight = 200.0;

  /// Minimum lines for JavaScript input field
  static const int inputFieldMinLines = 1;

  // === Position and Spacing Constants ===

  /// Default X position for widget
  static const double defaultPositionX = 20.0;

  /// Default Y position for widget
  static const double defaultPositionY = 100.0;

  /// Default padding size
  static const double defaultPadding = 8.0;

  /// Large padding size
  static const double largePadding = 12.0;

  /// Small padding size
  static const double smallPadding = 4.0;

  /// Input field padding (all sides)
  static const double inputFieldPadding = 8.0;

  /// Spacing between history popup and input field
  static const double historyPopupSpacing = 8.0;

  /// Additional padding for fallback position calculation
  static const double fallbackPositionPadding = 16.0;

  // === History System Constants ===

  /// History popup width ratio (90% of monitor width)
  static const double historyPopupWidthRatio = 0.9;

  /// History popup height (for displaying 3 items)
  static const double historyPopupHeight = 160.0;

  /// Maximum display length for script text
  static const int scriptMaxDisplayLength = 50;

  /// Maximum number of history items to store
  static const int maxHistoryCount = 15;

  /// Default usage count
  static const int defaultUsageCount = 1;

  // === Floating Button Constants ===

  /// Floating button size
  static const double floatingButtonSize = 40.0;

  /// Floating button margin
  static const double floatingButtonMargin = 10.0;

  /// Floating button snap threshold
  static const double snapThreshold = 10.0;

  /// Initial X position for floating button
  static const double floatingButtonInitialX = 10.0;

  /// Initial Y position for floating button
  static const double floatingButtonInitialY = 100.0;

  /// Top margin for floating button SafeArea
  static const double floatingButtonSafeAreaTopMargin = 10.0;

  /// Floating button border width
  static const double floatingButtonBorderWidth = 2.0;

  /// Floating button icon size
  static const double floatingButtonIconSize = 20.0;

  /// Floating button border radius
  static const double floatingButtonBorderRadius = 20.0;

  // === Dropdown Constants ===

  /// Dropdown X offset
  static const double dropdownXOffset = 8.0;

  /// Dropdown Y offset
  static const double dropdownYOffset = 106.0;

  /// Dropdown width offset (excluding 16px on both sides)
  static const double dropdownWidthOffset = 16.0;

  /// Maximum dropdown height
  static const double dropdownMaxHeight = 200.0;

  /// Maximum length for WebView ID display
  static const int webViewIdMaxLength = 8;

  /// Maximum length for WebView URL display
  static const int webViewUrlMaxLength = 20;

  /// Status dot size (green/grey)
  static const double statusDotSize = 8.0;

  // === Color Constants ===

  /// Grey color indices (default)
  static const int greyColorIndex400 = 400;
  static const int greyColorIndex500 = 500;
  static const int greyColorIndex600 = 600;
  static const int greyColorIndex700 = 700;
  static const int greyColorIndex800 = 800;
  static const int greyColorIndex850 = 850;

  /// Alpha values
  static const double backgroundAlpha = 0.9;
  static const double floatingButtonAlpha = 0.5;
  static const double selectedItemAlpha = 0.3;

  // === Animation Constants ===

  /// Snap animation duration (milliseconds)
  static const int snapAnimationDuration = 400;

  // === Font Size Constants ===

  /// Very small font size
  static const double verySmallFontSize = 9.0;

  /// Small font size
  static const double smallFontSize = 10.0;

  /// Small font size (11)
  static const double smallFontSize11 = 11.0;

  /// Default font size
  static const double defaultFontSize = 12.0;

  /// Default icon size
  static const double defaultIconSize = 16.0;

  /// Large icon size
  static const double largeIconSize = 18.0;

  /// Web icon size
  static const double webIconSize = 20.0;

  // === Border and Corner Constants ===

  /// Small border radius
  static const double smallBorderRadius = 4.0;

  /// Default border radius
  static const double defaultBorderRadius = 8.0;

  /// Thin border width
  static const double thinBorderWidth = 0.5;

  /// Default border width
  static const double defaultBorderWidth = 1.0;

  /// Material elevation value
  static const double defaultElevation = 8.0;

  // === Console Constants ===

  /// Default maximum console log count
  static const int defaultMaxConsoleLogCount = 1000;

  /// Medium maximum console log count
  static const int mediumMaxConsoleLogCount = 500;

  /// Small maximum console log count
  static const int smallMaxConsoleLogCount = 100;

  /// Console output header height
  static const double consoleHeaderHeight = 24.0;

  /// Console item bottom margin
  static const double consoleItemBottomMargin = 2.0;

  /// JSON.stringify indentation size
  static const int jsonStringifyIndent = 2;

  // === Time Constants ===

  /// 1 minute (in minutes)
  static const int oneMinute = 1;

  /// 1 hour (in hours)
  static const int oneHour = 1;

  /// 1 day (in days)
  static const int oneDay = 1;

  // === Miscellaneous Constants ===

  /// Not found index
  static const int notFoundIndex = -1;

  /// Comparison result equal
  static const int compareEqual = 0;

  /// Line number (user input)
  static const int userInputLineNumber = 0;

  /// Maximum lines (default)
  static const int defaultMaxLines = 1;

  /// Clamp minimum value
  static const double clampMinValue = 0.0;

  /// Center divider value
  static const double centerDivider = 2.0;
}
