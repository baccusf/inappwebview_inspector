import 'package:flutter/material.dart';

// Size modes for WebView inspector
enum InAppWebViewInspectorSizeMode {
  minimal,
  medium,
  maximized,
}

/// Header widget for InAppWebView Inspector
/// Handles title display and control buttons (minimize, medium, maximize, close)
class InAppWebViewInspectorHeaderWidget extends StatelessWidget {
  final InAppWebViewInspectorSizeMode currentSizeMode;
  final VoidCallback onMinimize;
  final VoidCallback onMedium;
  final VoidCallback onMaximize;
  final VoidCallback onClose;

  const InAppWebViewInspectorHeaderWidget({
    super.key,
    required this.currentSizeMode,
    required this.onMinimize,
    required this.onMedium,
    required this.onMaximize,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.web, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'WebView Monitor',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          // Compact button group with reduced spacing
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeaderButton(
                onPressed: onMinimize,
                icon: Icons.minimize,
                color: Colors.white,
                size: 16,
                tooltip: '최소화',
              ),
              _buildHeaderButton(
                onPressed: onMedium,
                icon: Icons.crop_square,
                color: currentSizeMode == InAppWebViewInspectorSizeMode.medium
                    ? Colors.blue
                    : Colors.white,
                size: 16,
                tooltip: '중간',
              ),
              _buildHeaderButton(
                onPressed: onMaximize,
                icon: Icons.maximize,
                color:
                    currentSizeMode == InAppWebViewInspectorSizeMode.maximized
                        ? Colors.blue
                        : Colors.white,
                size: 16,
                tooltip: '최대',
              ),
              _buildHeaderButton(
                onPressed: onClose,
                icon: Icons.close,
                color: Colors.white,
                size: 18,
                tooltip: '모니터 숨기기',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
    required double size,
    required String tooltip,
  }) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: color,
          size: size,
        ),
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        splashRadius: 16,
      ),
    );
  }
}
