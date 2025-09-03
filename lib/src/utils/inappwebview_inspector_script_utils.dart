/// JavaScript execution utilities for handling different result types
class InAppWebViewInspectorScriptUtils {
  // Disable constructor
  const InAppWebViewInspectorScriptUtils._();

  /// Common unsupported types and their detection patterns
  static const Map<String, String> unsupportedTypePatterns = {
    'NodeList': 'querySelectorAll',
    'HTMLElement': 'querySelector|getElementById|getElementsBy',
    'HTMLCollection': 'getElementsBy|children',
    'DOMTokenList': 'classList',
    'CSSStyleDeclaration': 'style',
    'Function': 'function',
    'Promise': 'Promise|async|await',
  };

  /// Suggestions for common unsupported operations
  static const Map<String, List<String>> typeSuggestions = {
    'NodeList': [
      'Use Array.from(document.querySelectorAll("selector")).length to get count',
      'Use Array.from(document.querySelectorAll("selector")).map(el => el.textContent) to get text contents',
      'Use Array.from(document.querySelectorAll("selector")).map(el => ({tagName: el.tagName, textContent: el.textContent})) to get element info',
    ],
    'HTMLElement': [
      'Use element.textContent to get text content',
      'Use element.tagName to get tag name',
      'Use element.className to get CSS classes',
      'Use {tagName: element.tagName, textContent: element.textContent, className: element.className} to get element info',
    ],
    'HTMLCollection': [
      'Use Array.from(collection).length to get count',
      'Use Array.from(collection).map(el => el.textContent) to get text contents',
    ],
    'DOMTokenList': [
      'Use Array.from(element.classList) to get class names as array',
      'Use element.className to get classes as string',
    ],
    'CSSStyleDeclaration': [
      'Use getComputedStyle(element).propertyName to get specific style property',
      'Use element.style.cssText to get inline styles as text',
    ],
    'Function': [
      'Functions cannot be returned. Execute the function and return its result instead',
      'Use function.toString() to get function source code as string',
    ],
    'Promise': [
      'Use await or .then() to resolve Promise before returning',
      'Promises cannot be directly returned to Flutter',
    ],
  };

  /// Detect potential unsupported type from script content
  static String? detectUnsupportedType(String script) {
    final scriptLower = script.toLowerCase();

    for (final entry in unsupportedTypePatterns.entries) {
      final type = entry.key;
      final pattern = entry.value;

      if (RegExp(pattern, caseSensitive: false).hasMatch(scriptLower)) {
        return type;
      }
    }

    return null;
  }

  /// Get suggestions for handling unsupported type
  static List<String> getSuggestions(String? unsupportedType) {
    if (unsupportedType == null) {
      return [];
    }
    return typeSuggestions[unsupportedType] ?? [];
  }

  /// Create enhanced error message with suggestions
  static String createEnhancedErrorMessage(
      String originalError, String script) {
    final unsupportedType = detectUnsupportedType(script);
    final suggestions = getSuggestions(unsupportedType);

    final buffer = StringBuffer();
    buffer.writeln('❌ JavaScript Execution Error');
    buffer.writeln('Original: $originalError');

    if (unsupportedType != null) {
      buffer.writeln(
          '\n💡 Detected Issue: $unsupportedType cannot be serialized to Flutter');
      buffer.writeln('\n🔧 Try these alternatives:');
      for (int i = 0; i < suggestions.length; i++) {
        buffer.writeln('${i + 1}. ${suggestions[i]}');
      }
    } else if (originalError.contains('unsupported type')) {
      buffer.writeln(
          '\n💡 This happens when JavaScript returns objects that cannot be converted to Flutter types');
      buffer.writeln('\n🔧 General solutions:');
      buffer.writeln('1. Convert objects to JSON: JSON.stringify(yourObject)');
      buffer.writeln(
          '2. Extract specific properties: {prop1: obj.prop1, prop2: obj.prop2}');
      buffer.writeln(
          '3. Convert to primitive types: obj.toString() or obj.valueOf()');
    }

    return buffer.toString();
  }

  /// Wrap script to handle common unsupported types automatically
  static String wrapScriptForSafeSerialization(String script) {
    final trimmedScript = script.trim();

    // If script looks like it returns a NodeList, auto-convert to array of info objects
    if (RegExp(r'document\.querySelectorAll\s*\([^)]+\)\s*$')
        .hasMatch(trimmedScript)) {
      return '''
        (function() {
          try {
            const nodeList = $trimmedScript;
            return Array.from(nodeList).map(el => ({
              tagName: el.tagName,
              textContent: el.textContent?.trim() || '',
              className: el.className || '',
              id: el.id || '',
              outerHTML: el.outerHTML?.substring(0, 200) || '' // Limit length
            }));
          } catch (e) {
            return { error: e.message };
          }
        })()
      ''';
    }

    // If script looks like it returns a single HTMLElement
    if (RegExp(
            r'document\.querySelector\s*\([^)]+\)\s*$|document\.getElementById\s*\([^)]+\)\s*$')
        .hasMatch(trimmedScript)) {
      return '''
        (function() {
          try {
            const element = $trimmedScript;
            if (!element) {
              return null;
            }
            return {
              tagName: element.tagName,
              textContent: element.textContent?.trim() || '',
              className: element.className || '',
              id: element.id || '',
              outerHTML: element.outerHTML?.substring(0, 200) || ''
            };
          } catch (e) {
            return { error: e.message };
          }
        })()
      ''';
    }

    // If script looks like it accesses classList
    if (RegExp(r'\.classList\s*$').hasMatch(trimmedScript)) {
      return '''
        (function() {
          try {
            const classList = $trimmedScript;
            return Array.from(classList);
          } catch (e) {
            return { error: e.message };
          }
        })()
      ''';
    }

    // For other scripts, wrap in a safer way that handles various return types
    return '''
      (function() {
        try {
          const result = $trimmedScript;
          
          // Handle different result types
          if (result === undefined) {
            return '(undefined)';
          }
          
          if (result === null) {
            return null;
          }
          
          // Check if it's a DOM node
          if (result && typeof result === 'object' && result.nodeType) {
            return {
              type: 'DOM_ELEMENT',
              tagName: result.tagName || 'unknown',
              textContent: result.textContent?.trim() || '',
              className: result.className || '',
              id: result.id || ''
            };
          }
          
          // Check if it's a NodeList or HTMLCollection
          if (result && (result instanceof NodeList || result instanceof HTMLCollection)) {
            return {
              type: 'NODE_COLLECTION',
              length: result.length,
              items: Array.from(result).slice(0, 5).map(el => ({
                tagName: el.tagName || 'unknown',
                textContent: el.textContent?.trim() || '',
                className: el.className || '',
                id: el.id || ''
              }))
            };
          }
          
          // Check if it's a function
          if (typeof result === 'function') {
            return {
              type: 'FUNCTION',
              name: result.name || 'anonymous',
              source: result.toString().substring(0, 100) + '...'
            };
          }
          
          // Try to return the result directly for primitive types and plain objects
          return result;
        } catch (e) {
          return { error: e.message, type: 'EXECUTION_ERROR' };
        }
      })()
    ''';
  }

  /// Check if a script is likely to cause serialization issues
  static bool mightCauseSerializationIssue(String script) {
    final unsupportedType = detectUnsupportedType(script);
    return unsupportedType != null;
  }

  /// Get a user-friendly warning message for potentially problematic scripts
  static String? getWarningMessage(String script) {
    final unsupportedType = detectUnsupportedType(script);

    if (unsupportedType != null) {
      return '⚠️ This script might return $unsupportedType which cannot be directly shown. Consider using one of the suggested alternatives.';
    }

    return null;
  }
}
