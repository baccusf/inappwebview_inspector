import 'package:flutter/material.dart';

// 포커스 컨트롤러
class InAppWebViewInspectorFocusController {
  final FocusNode focusNode;
  final VoidCallback? onFocusGained;
  final VoidCallback? onFocusLost;
  final Function(String)? onTextChanged;

  bool _isManuallyClosedByX = false;

  InAppWebViewInspectorFocusController({
    required this.focusNode,
    this.onFocusGained,
    this.onFocusLost,
    this.onTextChanged,
  });

  void initialize() {
    focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (focusNode.hasFocus) {
      onFocusGained?.call();
    } else {
      onFocusLost?.call();
    }
  }

  void handleTextChanged(String text) {
    onTextChanged?.call(text);
  }

  void setManuallyClosedByX(bool value) {
    _isManuallyClosedByX = value;
  }

  bool get isManuallyClosedByX => _isManuallyClosedByX;

  void dispose() {
    focusNode.removeListener(_handleFocusChange);
  }
}
