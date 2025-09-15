import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:async';
import '../core/inappwebview_inspector_interface.dart';
import '../core/inappwebview_inspector_factory.dart';
import '../core/inappwebview_inspector_impl.dart';
import '../services/inappwebview_inspector_script_history_manager.dart';
import '../services/inappwebview_inspector_script_history.dart';
import 'inappwebview_inspector_script_history_controller.dart';
import 'inappwebview_inspector_focus_controller.dart';
import 'inappwebview_inspector_header_widget.dart';
import '../utils/inappwebview_inspector_constants.dart';
import '../utils/inappwebview_inspector_localizations.dart';

// Size calculation helper extension
extension InAppWebViewInspectorSizeModeExtension
    on InAppWebViewInspectorSizeMode {
  /// Get the size for this mode
  Size getSize(Size? maximizedSize, double screenWidth) {
    final width =
        (screenWidth * InAppWebViewInspectorConstants.widgetScreenRatio).clamp(
            InAppWebViewInspectorConstants.defaultWidgetWidth, double.infinity);

    switch (this) {
      case InAppWebViewInspectorSizeMode.minimal:
        return const Size(60, 40); // Fixed compact size for minimal mode
      case InAppWebViewInspectorSizeMode.medium:
        return Size(width, InAppWebViewInspectorConstants.defaultWidgetHeight);
      case InAppWebViewInspectorSizeMode.maximized:
        return maximizedSize ??
            Size(width, InAppWebViewInspectorConstants.defaultWidgetHeight);
    }
  }
}

class InAppWebViewInspectorWidget extends StatefulWidget {
  final InAppWebViewInspectorInterface? inspector;
  final InAppWebViewInspectorConfig? config;

  const InAppWebViewInspectorWidget({
    super.key,
    this.inspector,
    this.config,
  });

  @override
  State<InAppWebViewInspectorWidget> createState() =>
      _InAppWebViewInspectorWidgetState();
}

class _InAppWebViewInspectorWidgetState
    extends State<InAppWebViewInspectorWidget> {
  late InAppWebViewInspectorInterface _inspector;
  late InAppWebViewInspectorConfig _config;
  final TextEditingController _scriptController = TextEditingController();

  /// Get the current localizations
  InAppWebViewInspectorLocalizations get _localizations =>
      _config.localizations;
  final ScrollController _consoleScrollController = ScrollController();
  final FocusNode _scriptFocusNode = FocusNode();

  // 스크립트 히스토리 관련
  InAppWebViewInspectorScriptHistoryManager? _historyManager;
  InAppWebViewInspectorScriptHistoryController? _historyController;
  InAppWebViewInspectorFocusController? _focusController;

  Offset _position = const Offset(
      InAppWebViewInspectorConstants.defaultPositionX,
      InAppWebViewInspectorConstants.defaultPositionY);
  Size _size = const Size(InAppWebViewInspectorConstants.defaultWidgetWidth,
      InAppWebViewInspectorConstants.defaultWidgetHeight);
  bool _isDragging = false;

  // Size modes
  InAppWebViewInspectorSizeMode _sizeMode =
      InAppWebViewInspectorSizeMode.medium;
  InAppWebViewInspectorSizeMode _previousSizeMode =
      InAppWebViewInspectorSizeMode
          .medium; // Store previous mode for restoration

  // Size constants
  late Size _maximizedSize;
  Size _safeAreaSize = Size.zero;

  // Stream subscriptions
  StreamSubscription<List<InAppWebViewInspectorConsoleMessage>>?
      _consoleLogsSubscription;
  StreamSubscription<String>? _activeWebViewSubscription;
  StreamSubscription<bool>? _visibilitySubscription;
  StreamSubscription<Map<String, InAppWebViewInspectorInstance>>?
      _webViewsSubscription;

  // State variables
  List<InAppWebViewInspectorConsoleMessage> _consoleLogs = [];
  String _activeWebViewId = '';
  bool _isInspectorVisible = false;
  Map<String, InAppWebViewInspectorInstance> _webViews = {};

  // 오버레이 상태 (더 이상 매니저 필요 없음)

  // UI 상태
  double _inputFieldHeight =
      InAppWebViewInspectorConstants.defaultInputFieldHeight;
  final GlobalKey _inputFieldKey = GlobalKey();

  // 히스토리 관련 상태
  List<InAppWebViewInspectorScriptHistory> _scriptHistory = [];
  bool _isHistoryPopupOpen = false;
  bool _isHistoryManuallyClosedByX = false;
  String _lastTextValue = '';
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _initializeInspector();
    _subscribeToStreams();
    _initializeScriptHistory();
    _setupFocusListener();
    _setupTextChangeListener();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screenSize = MediaQuery.of(context).size;
    final safeArea = MediaQuery.of(context).padding;

    final availableWidth = screenSize.width;
    final availableHeight = screenSize.height - safeArea.top - safeArea.bottom;

    _maximizedSize = Size(availableWidth, availableHeight);
    _size = _sizeMode.getSize(_maximizedSize, screenSize.width);
  }

  void _initializeInspector() {
    if (widget.inspector != null) {
      _inspector = widget.inspector as InAppWebViewInspectorInterface;
      _config = widget.config ?? InAppWebViewInspectorConfig.defaultConfig;
    } else if (InAppWebViewInspectorService.isRegistered) {
      _inspector = InAppWebViewInspectorService.inspector;
      _config = widget.config ?? InAppWebViewInspectorConfig.defaultConfig;
    } else {
      if (widget.config != null) {
        InAppWebViewInspectorFactory.initialize(config: widget.config);
        _config = widget.config!;
      } else {
        _config = InAppWebViewInspectorConfig.defaultConfig;
      }
      _inspector = InAppWebViewInspectorFactory.getInstance();
      InAppWebViewInspectorService.register(_inspector);
    }
  }

  void _subscribeToStreams() {
    if (_inspector is InAppWebViewInspectorImpl) {
      final impl = _inspector as InAppWebViewInspectorImpl;

      _consoleLogsSubscription = impl.consoleLogsStream.listen((logs) {
        if (mounted) {
          setState(() {
            _consoleLogs = logs;
          });
        }
      });

      _activeWebViewSubscription = impl.activeWebViewIdStream.listen((id) {
        if (mounted) {
          setState(() {
            _activeWebViewId = id;
          });
        }
      });

      _visibilitySubscription = impl.isInspectorVisibleStream.listen((visible) {
        if (mounted) {
          setState(() {
            _isInspectorVisible = visible;
          });
        }
      });

      _webViewsSubscription = impl.webViewsStream.listen((webViews) {
        if (mounted) {
          setState(() {
            _webViews = webViews;
          });
        }
      });
    }

    setState(() {
      _consoleLogs = _inspector.consoleLogs;
      _activeWebViewId = _inspector.activeWebViewId;
      _isInspectorVisible = _inspector.isInspectorVisible;
      _webViews = _inspector.webViews;
    });
  }

  void _initializeScriptHistory() {
    try {
      _historyManager = InAppWebViewInspectorScriptHistoryManager();
      if (mounted) {
        final historyManager = _historyManager;
        if (historyManager != null) {
          _historyController =
              InAppWebViewInspectorScriptHistoryController(historyManager);
          _historyController?.addListener(() {
            if (mounted) {
              setState(() {
                // 히스토리 컨트롤러가 상태 업데이트
              });
            }
          });
        }
      }
    } catch (e) {
      // 히스토리 매니저 초기화 실패 시 무시
    }
  }

  void _setupFocusListener() {
    _focusController = InAppWebViewInspectorFocusController(
      focusNode: _scriptFocusNode,
      onFocusGained: () {
        _updateInputFieldHeight();
        _showHistoryPopup();
      },
      onFocusLost: () {
        _closeHistoryPopup();
      },
      onTextChanged: (text) {
        // 텍스트 변경 처리
      },
    );
    _focusController?.initialize();
  }

  void _setupTextChangeListener() {
    _scriptController.addListener(() {
      final newText = _scriptController.text;
      _focusController?.handleTextChanged(newText);
    });
  }

  void _handleTextChange() {
    final currentText = _scriptController.text;

    if (_hasTextChanged(currentText)) {
      _lastTextValue = currentText;
      _handleHistoryPopupForTextChange();
    }
  }

  bool _hasTextChanged(String currentText) {
    return currentText != _lastTextValue;
  }

  void _handleHistoryPopupForTextChange() {
    if (_shouldShowHistoryPopup()) {
      _resetManualCloseState();
      _showHistoryPopup();
    }
  }

  bool _shouldShowHistoryPopup() {
    return _scriptFocusNode.hasFocus && !_isHistoryPopupOpen;
  }

  void _resetManualCloseState() {
    if (_isHistoryManuallyClosedByX) {
      _focusController?.setManuallyClosedByX(false);
      _isHistoryManuallyClosedByX = false;
    }
  }

  void _updateInputFieldHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureAndUpdateInputFieldHeight();
    });
  }

  void _measureAndUpdateInputFieldHeight() {
    final renderBox = _getInputFieldRenderBox();
    if (renderBox == null) {
      return;
    }

    final newHeight = renderBox.size.height;
    if (_isInputFieldHeightChanged(newHeight)) {
      _updateInputFieldHeightState(newHeight);
      _updateHistoryPopupPosition();
    }
  }

  RenderBox? _getInputFieldRenderBox() {
    return _inputFieldKey.currentContext?.findRenderObject() as RenderBox?;
  }

  bool _isInputFieldHeightChanged(double newHeight) {
    return newHeight != _inputFieldHeight;
  }

  void _updateInputFieldHeightState(double newHeight) {
    setState(() {
      _inputFieldHeight = newHeight;
    });
  }

  void _updateHistoryPopupPosition() {
    if (_isHistoryPopupOpen) {
      _isHistoryManuallyClosedByX = false;
      _closeHistoryPopup();
      _showHistoryPopup();
    }
  }

  void _closeHistoryPopup() {
    setState(() {
      _isHistoryPopupOpen = false;
    });
  }

  void _closeHistoryPopupByX() {
    _focusController?.setManuallyClosedByX(true);
    _closeHistoryPopup();
  }

  void _showHistoryPopup() {
    if (_isHistoryPopupOpen) {
      return;
    }

    final history = _historyController?.history ?? _scriptHistory;
    setState(() {
      _isHistoryPopupOpen = true;
      _scriptHistory = history;
    });
  }

  Offset _calculateHistoryPopupPosition() {
    final popupWidth =
        _size.width * InAppWebViewInspectorConstants.historyPopupWidthRatio;
    final popupLeft = _position.dx +
        (_size.width - popupWidth) /
            InAppWebViewInspectorConstants.centerDivider;

    // Position history popup right below the entire JavaScript input view area
    // This includes the "Console:" label, input field, and execute button area
    final headerHeight = 50.0; // _buildHeader height
    final selectorHeight = 60.0; // _buildWebViewSelector height (approximately)
    final consoleLabelHeight = 16.0; // "Console:" text + spacing
    final inputViewHeight =
        _inputFieldHeight.clamp(32.0, 200.0); // input field height
    final inputViewPadding = 8.0; // bottom padding of input view

    final inputViewBottom = _position.dy +
        headerHeight +
        selectorHeight +
        consoleLabelHeight +
        inputViewHeight +
        inputViewPadding;

    final popupTop =
        inputViewBottom + InAppWebViewInspectorConstants.historyPopupSpacing;

    return Offset(popupLeft, popupTop);
  }

  Widget _buildHistoryPopupContent(
      List<InAppWebViewInspectorScriptHistory> history,
      VoidCallback closeCallback) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHistoryPopupHeader(),
        _buildHistoryPopupBody(history),
      ],
    );
  }

  Widget _buildHistoryPopupHeader() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(InAppWebViewInspectorConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.grey[InAppWebViewInspectorConstants.greyColorIndex700],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(
              InAppWebViewInspectorConstants.defaultBorderRadius),
          topRight: Radius.circular(
              InAppWebViewInspectorConstants.defaultBorderRadius),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _localizations.history,
              style: const TextStyle(
                color: Colors.white,
                fontSize: InAppWebViewInspectorConstants.defaultFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: _closeHistoryPopupByX,
            child: const Icon(
              Icons.close,
              color: Colors.white,
              size: InAppWebViewInspectorConstants.defaultIconSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryPopupBody(
      List<InAppWebViewInspectorScriptHistory> history) {
    if (history.isEmpty) {
      return _buildEmptyHistoryMessage();
    }

    return Flexible(
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: history.length,
        itemBuilder: (context, index) => _buildHistoryItem(history[index]),
      ),
    );
  }

  Widget _buildEmptyHistoryMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: InAppWebViewInspectorConstants.defaultPadding,
          vertical: InAppWebViewInspectorConstants.defaultPadding),
      child: Text(
        _localizations.noHistory,
        style: const TextStyle(
            color: Colors.grey,
            fontSize: InAppWebViewInspectorConstants.defaultFontSize),
      ),
    );
  }

  Widget _buildHistoryItem(InAppWebViewInspectorScriptHistory item) {
    return GestureDetector(
      onTap: () => _selectHistoryItem(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[700] ?? Colors.grey,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _truncateScript(item.script,
                    InAppWebViewInspectorConstants.scriptMaxDisplayLength),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: InAppWebViewInspectorConstants.smallFontSize11,
                ),
              ),
            ),
            const SizedBox(
                width: InAppWebViewInspectorConstants.defaultPadding),
            _buildHistoryItemInfo(item),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItemInfo(InAppWebViewInspectorScriptHistory item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${item.usageCount}회',
          style: TextStyle(
            color:
                Colors.grey[InAppWebViewInspectorConstants.greyColorIndex400],
            fontSize: InAppWebViewInspectorConstants.smallFontSize,
          ),
        ),
        Text(
          _formatTimeAgo(item.timestamp),
          style: TextStyle(
            color:
                Colors.grey[InAppWebViewInspectorConstants.greyColorIndex500],
            fontSize: InAppWebViewInspectorConstants.verySmallFontSize,
          ),
        ),
      ],
    );
  }

  String _truncateScript(String script, int maxLength) {
    return script.length > maxLength
        ? '${script.substring(0, maxLength)}...'
        : script;
  }

  @override
  void dispose() {
    _scriptController.dispose();
    _consoleScrollController.dispose();
    _scriptFocusNode.dispose();
    _consoleLogsSubscription?.cancel();
    _activeWebViewSubscription?.cancel();
    _visibilitySubscription?.cancel();
    _webViewsSubscription?.cancel();
    _focusController?.dispose();
    _historyController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInspectorVisible) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          _safeAreaSize = Size(constraints.maxWidth, constraints.maxHeight);

          if (_sizeMode == InAppWebViewInspectorSizeMode.maximized) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _maximizedSize =
                    Size(constraints.maxWidth, constraints.maxHeight);
                _size = _sizeMode.getSize(_maximizedSize, constraints.maxWidth);
              });
            });
          }

          // Show minimal view when in minimal mode
          if (_sizeMode == InAppWebViewInspectorSizeMode.minimal) {
            return _buildMinimalView(constraints);
          }

          return Stack(
            children: [
              Positioned(
                left: _position.dx,
                top: _position.dy,
                child: SizedBox(
                  width: _size.width,
                  height: _size.height,
                  child: GestureDetector(
                    onPanStart: (details) {
                      setState(() {
                        _isDragging = true;
                      });
                      _scriptFocusNode.unfocus();
                      FocusScope.of(context).unfocus();
                      _closeCustomDropdown();
                      _closeHistoryPopup();
                    },
                    onPanUpdate: (details) {
                      if (_isDragging) {
                        setState(() {
                          double newX = (_position.dx + details.delta.dx)
                              .clamp(0.0, constraints.maxWidth - _size.width);
                          double newY = (_position.dy + details.delta.dy)
                              .clamp(0.0, constraints.maxHeight - _size.height);

                          _position = Offset(newX, newY);
                        });
                      }
                    },
                    onPanEnd: (details) {
                      setState(() {
                        _isDragging = false;
                      });
                    },
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        _scriptFocusNode.unfocus();
                        FocusScope.of(context).unfocus();
                      },
                      child: Material(
                        elevation: 8,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: _size.width,
                          height: _size.height,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade600),
                          ),
                          child: Column(
                            children: [
                              _buildHeader(),
                              _buildWebViewSelector(),
                              _buildConsoleInput(),
                              _buildConsoleOutput(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // History popup positioned above console input
              if (_isHistoryPopupOpen) _buildHistoryPopupPositioned(),
              // Dropdown positioned below webview selector
              if (_isDropdownOpen) _buildDropdownPositioned(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return InAppWebViewInspectorHeaderWidget(
      currentSizeMode: _sizeMode,
      onMinimize: _toggleToMinimalMode,
      onMedium: () => _setSizeMode(InAppWebViewInspectorSizeMode.medium),
      onMaximize: () => _setSizeMode(InAppWebViewInspectorSizeMode.maximized),
      onClose: () => _inspector.hideInspector(),
    );
  }

  Widget _buildWebViewSelector() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _localizations.activeWebView,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: _isDragging ? null : _toggleCustomDropdown,
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: _isDropdownOpen ? Colors.blue : Colors.transparent,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _getDisplayText(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                  Icon(
                    _isDropdownOpen
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayText() {
    if (_activeWebViewId.isEmpty || !_webViews.containsKey(_activeWebViewId)) {
      return '활성화된 WebView가 없습니다.';
    }

    final webView =
        _webViews[_activeWebViewId] as InAppWebViewInspectorInstance;
    return _buildWebViewDisplayText(_activeWebViewId, webView.url);
  }

  void _toggleCustomDropdown() {
    if (_isDropdownOpen) {
      _closeCustomDropdown();
    } else {
      _showCustomDropdown();
    }
  }

  void _showCustomDropdown() {
    if (_isDropdownOpen || _webViews.isEmpty) {
      return;
    }

    setState(() {
      _isDropdownOpen = true;
    });
  }

  void _closeCustomDropdown() {
    setState(() {
      _isDropdownOpen = false;
    });
  }

  Widget _buildDropdownContent(VoidCallback closeCallback) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _buildDropdownItems(closeCallback),
      ),
    );
  }

  List<Widget> _buildDropdownItems(VoidCallback closeCallback) {
    if (_webViews.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(12),
          child: const Text(
            '사용 가능한 WebView가 없습니다.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      ];
    }

    return _webViews.entries.map((entry) {
      final isSelected = entry.key == _activeWebViewId;
      return InkWell(
        onTap: () {
          _inspector.setActiveWebView(entry.key);
          closeCallback();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.blue.withValues(alpha: 0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: entry.value.isVisible ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _buildWebViewDisplayText(entry.key, entry.value.url),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.fade,
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check,
                  color: Colors.blue,
                  size: 16,
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  String _buildWebViewDisplayText(String webViewId, String url) {
    try {
      if (url.isEmpty) {
        return '$webViewId (읽는 중...)';
      }

      final uri = Uri.parse(url);
      String host = uri.host;

      if (host.isEmpty) {
        if (uri.scheme.isNotEmpty) {
          host = '${uri.scheme}://';
        } else {
          host = url;
        }
      }

      return '$webViewId ($host)';
    } catch (e) {
      final displayUrl = url.isEmpty ? 'URL 없음' : url;
      return '$webViewId ($displayUrl)';
    }
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < InAppWebViewInspectorConstants.oneMinute) {
      return '방금 전';
    } else if (difference.inHours < InAppWebViewInspectorConstants.oneHour) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < InAppWebViewInspectorConstants.oneDay) {
      return '${difference.inHours}시간 전';
    } else {
      return '${difference.inDays}일 전';
    }
  }

  void _selectHistoryItem(InAppWebViewInspectorScriptHistory historyItem) {
    _scriptController.text = historyItem.script;
    _scriptController.selection = TextSelection.fromPosition(
      TextPosition(offset: historyItem.script.length),
    );
    _historyController?.addScript(historyItem.script);
  }

  Widget _buildConsoleInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Console:',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  key: _inputFieldKey,
                  constraints: const BoxConstraints(
                    minHeight: 32,
                    maxHeight: 200,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextField(
                    controller: _scriptController,
                    focusNode: _scriptFocusNode,
                    maxLines: null,
                    minLines: 1,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    onChanged: (_) {
                      _updateInputFieldHeight();
                      _handleTextChange();
                    },
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                    decoration: InputDecoration(
                      hintText: _localizations.javascriptPlaceholder,
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () {
                          _scriptFocusNode.unfocus();
                          FocusScope.of(context).unfocus();
                          _executeScript(_scriptController.text);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                        ),
                        child: Text(
                          _localizations.execute,
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConsoleOutput() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade600),
        ),
        child: Column(
          children: [
            Container(
              height: 24,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    _localizations.consoleOutput,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _inspector.clearConsoleLogs,
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _consoleScrollController,
                padding: const EdgeInsets.all(4),
                itemCount: _consoleLogs.length,
                itemBuilder: (context, index) {
                  final log = _consoleLogs[index];
                  return _buildConsoleLogItem(log);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsoleLogItem(InAppWebViewInspectorConsoleMessage log) {
    final isResultMessage = log.message.startsWith('>>');

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: log.level == ConsoleMessageLevel.ERROR
            ? Colors.red.withValues(alpha: 0.1)
            : isResultMessage
                ? Colors.blue.withValues(alpha: 0.05)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: log.levelColor,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  log.levelText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}:${log.timestamp.second.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 8,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '[${log.webViewId}]',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 8,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            log.message,
            style: TextStyle(
              color: log.level == ConsoleMessageLevel.ERROR
                  ? Colors.red.shade300
                  : isResultMessage
                      ? Colors.blue.shade200
                      : Colors.white,
              fontSize: 10,
              fontFamily: 'monospace',
            ),
            maxLines: null, // Allow unlimited lines
            softWrap: true, // Enable text wrapping
          ),
          if (log.source != null && log.line != null)
            Text(
              '${log.source}:${log.line}',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 8,
              ),
            ),
        ],
      ),
    );
  }

  void _executeScript(String script) {
    if (script.trim().isEmpty) return;

    _historyController?.addScript(script.trim());
    _inspector.executeScript(script);
    _scriptController.clear();

    _inspector.addCustomConsoleLog(InAppWebViewInspectorConsoleMessage(
      webViewId: _activeWebViewId,
      level: ConsoleMessageLevel.LOG,
      message: '> $script',
      source: null,
      line: null,
      timestamp: DateTime.now(),
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_consoleScrollController.hasClients) {
        _consoleScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _setSizeMode(InAppWebViewInspectorSizeMode mode) {
    setState(() {
      // Store previous mode for restoration (but don't store minimal mode)
      if (_sizeMode != InAppWebViewInspectorSizeMode.minimal) {
        _previousSizeMode = _sizeMode;
      }

      _sizeMode = mode;
      _size = mode.getSize(_maximizedSize, _safeAreaSize.width);

      if (mode == InAppWebViewInspectorSizeMode.maximized) {
        _position = const Offset(0, 0);
      }

      if (mode != InAppWebViewInspectorSizeMode.maximized) {
        _position = Offset(
          _position.dx.clamp(0.0, _safeAreaSize.width - _size.width),
          _position.dy.clamp(0.0, _safeAreaSize.height - _size.height),
        );
      }

      // Close popups when switching to minimal mode
      if (mode == InAppWebViewInspectorSizeMode.minimal) {
        _closeHistoryPopup();
        _closeCustomDropdown();
        _scriptFocusNode.unfocus();
        FocusScope.of(context).unfocus();
      }
    });
  }

  void _toggleToMinimalMode() {
    _setSizeMode(InAppWebViewInspectorSizeMode.minimal);
  }

  void _restoreFromMinimalMode() {
    _setSizeMode(_previousSizeMode);
  }

  Widget _buildMinimalView(BoxConstraints constraints) {
    return Stack(
      children: [
        Positioned(
          left: _position.dx,
          top: _position.dy,
          child: SizedBox(
            width: _size.width,
            height: _size.height,
            child: GestureDetector(
              onPanStart: (details) {
                setState(() {
                  _isDragging = true;
                });
              },
              onPanUpdate: (details) {
                if (_isDragging) {
                  setState(() {
                    double newX = (_position.dx + details.delta.dx)
                        .clamp(0.0, constraints.maxWidth - _size.width);
                    double newY = (_position.dy + details.delta.dy)
                        .clamp(0.0, constraints.maxHeight - _size.height);

                    _position = Offset(newX, newY);
                  });
                }
              },
              onPanEnd: (details) {
                setState(() {
                  _isDragging = false;
                });
              },
              child: GestureDetector(
                onTap: _restoreFromMinimalMode,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: _size.width,
                    height: _size.height,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade600),
                    ),
                    child: Center(
                      child: Stack(
                        children: [
                          const Icon(
                            Icons.web,
                            color: Colors.white,
                            size: 20,
                          ),
                          // Show a small dot if there are active WebViews
                          if (_webViews.isNotEmpty)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          // Show red dot if there are new console messages
                          if (_consoleLogs.isNotEmpty &&
                              _consoleLogs.any((log) =>
                                  log.level == ConsoleMessageLevel.ERROR))
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryPopupPositioned() {
    final position = _calculateHistoryPopupPosition();
    final safeAreaSize = _safeAreaSize;

    // Calculate responsive size with bounds checking
    final maxWidth =
        (_size.width * InAppWebViewInspectorConstants.historyPopupWidthRatio)
            .clamp(200.0, safeAreaSize.width - 40);
    final maxHeight = InAppWebViewInspectorConstants.historyPopupHeight
        .clamp(120.0, safeAreaSize.height - 100);
    final size = Size(maxWidth, maxHeight);

    // Ensure popup stays within screen bounds with padding
    final adjustedLeft = position.dx.clamp(20.0,
        (safeAreaSize.width - size.width - 20.0).clamp(20.0, double.infinity));
    final adjustedTop = position.dy.clamp(
        20.0,
        (safeAreaSize.height - size.height - 20.0)
            .clamp(20.0, double.infinity));

    return Positioned(
      left: adjustedLeft,
      top: adjustedTop,
      width: size.width,
      height: size.height,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade700,
        child: _buildHistoryPopupContent(_scriptHistory, _closeHistoryPopup),
      ),
    );
  }

  Widget _buildDropdownPositioned() {
    // Position dropdown right below the WebView selector
    final selectorBottom =
        _position.dy + 50 + 60; // header height + selector height
    final position = Offset(_position.dx + 8, selectorBottom);
    final safeAreaSize = _safeAreaSize;

    // Calculate responsive size with bounds checking
    final maxWidth = (_size.width - 16).clamp(200.0, safeAreaSize.width - 40);
    final maxHeight = 200.0.clamp(120.0, safeAreaSize.height - 200);
    final size = Size(maxWidth, maxHeight);

    // Ensure dropdown stays within screen bounds with padding
    final adjustedLeft = position.dx.clamp(20.0,
        (safeAreaSize.width - size.width - 20.0).clamp(20.0, double.infinity));
    final adjustedTop = position.dy.clamp(
        20.0,
        (safeAreaSize.height - size.height - 20.0)
            .clamp(20.0, double.infinity));

    return Positioned(
      left: adjustedLeft,
      top: adjustedTop,
      width: size.width,
      height: size.height,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(4),
        color: Colors.grey.shade800,
        child: _buildDropdownContent(_closeCustomDropdown),
      ),
    );
  }
}
