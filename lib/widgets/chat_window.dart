import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class WaibyChatMessage {
  final String text;
  final bool fromCurrentUser;
  final DateTime sentAt;

  const WaibyChatMessage({
    required this.text,
    required this.fromCurrentUser,
    required this.sentAt,
  });
}

@immutable
class WaibyChatThread {
  final String id;
  final String displayName;
  final String avatarAsset;
  final String? frameAsset;
  final String previewText;
  final bool previewItalic;
  final String lastActivityLabel;
  final int unreadCount;
  final bool showUnreadIndicator;
  final bool isOnline;
  final List<WaibyChatMessage> messages;

  WaibyChatThread({
    required this.id,
    required this.displayName,
    required this.avatarAsset,
    this.frameAsset,
    required this.previewText,
    this.previewItalic = false,
    required this.lastActivityLabel,
    this.unreadCount = 0,
    this.showUnreadIndicator = false,
    this.isOnline = false,
    List<WaibyChatMessage> messages = const <WaibyChatMessage>[],
  }) : messages = List<WaibyChatMessage>.unmodifiable(messages);

  static List<WaibyChatThread> demoThreads() {
    final anchorTime = DateTime(2026, 1, 21, 8, 50);
    return <WaibyChatThread>[
      WaibyChatThread(
        id: 'arvkiny',
        displayName: 'Arvkiny',
        avatarAsset: 'assets/pp1.png',
        frameAsset: 'assets/medals/vine_wreath.png',
        previewText: 'we can echat',
        lastActivityLabel: 'now',
        unreadCount: 1,
        showUnreadIndicator: true,
        isOnline: true,
        messages: <WaibyChatMessage>[
          WaibyChatMessage(
            text: 'Hello, can i order?',
            fromCurrentUser: true,
            sentAt: anchorTime,
          ),
          WaibyChatMessage(
            text: 'hello! what u wanna order',
            fromCurrentUser: false,
            sentAt: anchorTime.add(const Duration(minutes: 1)),
          ),
          WaibyChatMessage(
            text: 'we can echat',
            fromCurrentUser: false,
            sentAt: anchorTime.add(const Duration(minutes: 2)),
          ),
        ],
      ),
      WaibyChatThread(
        id: 'miathekat',
        displayName: 'miatheKAT',
        avatarAsset: 'assets/pp2.png',
        frameAsset: 'assets/medals/kittybloom.png',
        previewText: 'Kirck just placed an ord...',
        previewItalic: true,
        lastActivityLabel: '1min ago',
      ),
      WaibyChatThread(
        id: 'issacthetuff',
        displayName: 'issacthetuff',
        avatarAsset: 'assets/pp3.png',
        previewText: 'whos??',
        lastActivityLabel: '1min ago',
      ),
      WaibyChatThread(
        id: 'ice',
        displayName: 'ICE',
        avatarAsset: 'assets/pp4.png',
        frameAsset: 'assets/medals/golden.png',
        previewText: 'bruh what',
        lastActivityLabel: '1min ago',
        unreadCount: 1,
        showUnreadIndicator: true,
      ),
      WaibyChatThread(
        id: 'tster',
        displayName: 'Tster',
        avatarAsset: 'assets/pp5.png',
        previewText: 'Tster has completed the or...',
        previewItalic: true,
        lastActivityLabel: '2min ago',
        unreadCount: 1,
        showUnreadIndicator: true,
      ),
      WaibyChatThread(
        id: 'weed1980',
        displayName: 'weed1980',
        avatarAsset: 'assets/pp6.png',
        frameAsset: 'assets/medals/lolita_pearl.png',
        previewText: 'no',
        lastActivityLabel: '5min ago',
        unreadCount: 1,
        showUnreadIndicator: true,
      ),
      WaibyChatThread(
        id: 'raion-shiro',
        displayName: 'Raion Shiro',
        avatarAsset: 'assets/pp7.png',
        frameAsset: 'assets/medals/aqua_ring.png',
        previewText: 'thats what i did idk',
        lastActivityLabel: '12min ago',
      ),
      WaibyChatThread(
        id: 'lilith',
        displayName: 'Lilith',
        avatarAsset: 'assets/pp2.png',
        frameAsset: 'assets/medals/lolita_pearl.png',
        previewText: 'LIlith offered a service of...',
        previewItalic: true,
        lastActivityLabel: '26min ago',
      ),
      WaibyChatThread(
        id: 'waxal',
        displayName: 'waxal',
        avatarAsset: 'assets/pp6.png',
        frameAsset: 'assets/medals/vine_wreath.png',
        previewText: 'Sure',
        lastActivityLabel: '40min ago',
      ),
      WaibyChatThread(
        id: 'nikkiex',
        displayName: 'Nikkiex',
        avatarAsset: 'assets/pp5.png',
        frameAsset: 'assets/medals/aurealux_emblem.png',
        previewText: 'smile',
        lastActivityLabel: '2h ago',
      ),
    ];
  }
}

Future<void> showWaibyChatDialog(
  BuildContext context, {
  List<WaibyChatThread>? threads,
  String? initialThreadId,
  bool barrierDismissible = true,
}) {
  final resolvedThreads = threads ?? WaibyChatThread.demoThreads();
  return showDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black.withValues(alpha: 0.7),
    builder: (dialogContext) {
      final size = MediaQuery.sizeOf(dialogContext);
      final width = (size.width - 24).clamp(320.0, 980.0).toDouble();
      final height = (size.height - 24).clamp(440.0, 860.0).toDouble();
      return Dialog(
        insetPadding: const EdgeInsets.all(12),
        backgroundColor: Colors.transparent,
        child: WaibyChatWindow(
          width: width,
          height: height,
          threads: resolvedThreads,
          initialThreadId: initialThreadId,
        ),
      );
    },
  );
}

class WaibyChatWindow extends StatefulWidget {
  final double width;
  final double height;
  final List<WaibyChatThread> threads;
  final String? initialThreadId;
  final VoidCallback? onClose;

  const WaibyChatWindow({
    super.key,
    required this.width,
    required this.height,
    required this.threads,
    this.initialThreadId,
    this.onClose,
  });

  @override
  State<WaibyChatWindow> createState() => _WaibyChatWindowState();
}

class _WaibyChatWindowState extends State<WaibyChatWindow> {
  late final List<_ThreadRuntime> _threads;
  late String _selectedThreadId;
  bool _showSettingsPanel = false;
  bool _chatOnlyNotifications = false;
  bool _showGiftPanel = false;
  _GiftCategory _activeGiftCategory = _GiftCategory.sweet;
  int _giftMultiplier = 1;
  String? _selectedGiftId;
  static const double _giftBalance = 12.80;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _messagesController = ScrollController();

  @override
  void initState() {
    super.initState();
    _threads =
        (widget.threads.isEmpty
                ? WaibyChatThread.demoThreads()
                : widget.threads)
            .map(_ThreadRuntime.fromThread)
            .toList(growable: false);

    _selectedThreadId = _resolveInitialThreadId();
    _markThreadRead(_selectedThread);

    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollMessagesToBottom(animated: false),
    );
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _messageController.dispose();
    _messagesController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant WaibyChatWindow oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextThreadId = widget.initialThreadId;
    if (nextThreadId == null || nextThreadId == oldWidget.initialThreadId) {
      return;
    }
    if (!_threads.any((thread) => thread.id == nextThreadId)) {
      return;
    }
    final thread = _threads.firstWhere((entry) => entry.id == nextThreadId);
    setState(() {
      _selectedThreadId = nextThreadId;
      _markThreadRead(thread);
    });
    _scrollMessagesToBottom(animated: false);
  }

  String _resolveInitialThreadId() {
    final id = widget.initialThreadId;
    if (id != null && _threads.any((thread) => thread.id == id)) {
      return id;
    }
    return _threads.first.id;
  }

  void _onSearchChanged() => setState(() {});

  List<_ThreadRuntime> get _filteredThreads {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _threads;
    }
    return _threads
        .where(
          (thread) =>
              thread.displayName.toLowerCase().contains(query) ||
              thread.previewText.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  _ThreadRuntime get _selectedThread {
    return _threads.firstWhere((thread) => thread.id == _selectedThreadId);
  }

  void _selectThread(String threadId) {
    final thread = _threads.firstWhere((entry) => entry.id == threadId);
    setState(() {
      _selectedThreadId = threadId;
      _markThreadRead(thread);
      _showGiftPanel = false;
      _showSettingsPanel = false;
    });
    _scrollMessagesToBottom(animated: false);
  }

  void _markThreadRead(_ThreadRuntime thread) {
    thread.unreadCount = 0;
    thread.showUnreadIndicator = false;
  }

  void _sendMessage() {
    final trimmed = _messageController.text.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final active = _selectedThread;
    setState(() {
      final sentAt = DateTime.now();
      active.messages.add(
        WaibyChatMessage(text: trimmed, fromCurrentUser: true, sentAt: sentAt),
      );
      active.previewText = trimmed;
      active.previewItalic = false;
      active.lastActivityLabel = 'now';
    });

    _messageController.clear();
    _scrollMessagesToBottom(animated: true);
  }

  void _toggleSettingsPanel() {
    setState(() {
      _showSettingsPanel = !_showSettingsPanel;
      if (_showSettingsPanel) {
        _showGiftPanel = false;
      }
    });
  }

  void _closeSettingsPanel() {
    if (!_showSettingsPanel) {
      return;
    }
    setState(() => _showSettingsPanel = false);
  }

  void _toggleGiftPanel() {
    setState(() {
      _showGiftPanel = !_showGiftPanel;
      if (_showGiftPanel) {
        _showSettingsPanel = false;
        final activeItems = _giftItemsByCategory[_activeGiftCategory]!;
        if (_selectedGiftId == null ||
            activeItems.every((item) => item.id != _selectedGiftId)) {
          _selectedGiftId = activeItems.first.id;
        }
      }
    });
  }

  void _closeFloatingPanels() {
    if (!_showGiftPanel && !_showSettingsPanel) {
      return;
    }
    setState(() {
      _showGiftPanel = false;
      _showSettingsPanel = false;
    });
  }

  List<_GiftItem> get _activeGiftItems {
    return _giftItemsByCategory[_activeGiftCategory]!;
  }

  void _selectGiftCategory(_GiftCategory category) {
    setState(() {
      _activeGiftCategory = category;
      final available = _giftItemsByCategory[category]!;
      if (available.every((item) => item.id != _selectedGiftId)) {
        _selectedGiftId = available.first.id;
      }
    });
  }

  void _selectGift(String giftId) {
    setState(() => _selectedGiftId = giftId);
  }

  void _cycleGiftMultiplier() {
    const values = <int>[1, 5, 10];
    final currentIndex = values.indexOf(_giftMultiplier);
    final nextIndex = currentIndex == -1
        ? 0
        : (currentIndex + 1) % values.length;
    setState(() => _giftMultiplier = values[nextIndex]);
  }

  void _sendGift() {
    final selectedId = _selectedGiftId;
    final gift = _activeGiftItems.firstWhere(
      (item) => item.id == selectedId,
      orElse: () => _activeGiftItems.first,
    );
    final active = _selectedThread;

    setState(() {
      active.messages.add(
        WaibyChatMessage(
          text: 'Sent ${gift.name} gift x$_giftMultiplier',
          fromCurrentUser: true,
          sentAt: DateTime.now(),
        ),
      );
      active.previewText = 'Sent ${gift.name} gift';
      active.previewItalic = false;
      active.lastActivityLabel = 'now';
      _showGiftPanel = false;
    });

    _scrollMessagesToBottom(animated: true);
  }

  void _scrollMessagesToBottom({required bool animated}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_messagesController.hasClients) {
        return;
      }
      final target = _messagesController.position.maxScrollExtent;
      if (animated) {
        _messagesController.animateTo(
          target,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      } else {
        _messagesController.jumpTo(target);
      }
    });
  }

  double _scaleByWidth(
    double width, {
    required double min,
    required double max,
    double minWidth = 560,
    double maxWidth = 1040,
  }) {
    if (max <= min) {
      return min;
    }
    if (width <= minWidth) {
      return min;
    }
    if (width >= maxWidth) {
      return max;
    }
    final t = (width - minWidth) / (maxWidth - minWidth);
    return min + ((max - min) * t);
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedThread;
    return LayoutBuilder(
      builder: (context, constraints) {
        final panelWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : widget.width;
        final panelHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : widget.height;
        final compact = panelWidth < 860;
        final tiny = panelWidth < 620;
        final cornerRadius = _scaleByWidth(panelWidth, min: 8, max: 12);
        final threadListWidth = math
            .min(320.0, panelWidth * 0.33)
            .clamp(210.0, 320.0)
            .toDouble();
        final outerPadding = tiny
            ? 10.0
            : _scaleByWidth(panelWidth, min: 11, max: 16);
        final sectionGap = _scaleByWidth(panelWidth, min: 8, max: 12);
        final threadListHeight = (panelHeight * 0.33)
            .clamp(170.0, 240.0)
            .toDouble();

        return Container(
          width: panelWidth,
          constraints: BoxConstraints(minHeight: 420, maxHeight: panelHeight),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(cornerRadius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(cornerRadius),
            child: Column(
              children: [
                _buildTopBar(
                  compact: compact,
                  panelWidth: panelWidth,
                  cornerRadius: cornerRadius,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      outerPadding,
                      0,
                      outerPadding,
                      outerPadding,
                    ),
                    child: compact
                        ? Column(
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: 180,
                                  maxHeight: threadListHeight,
                                ),
                                child: _buildThreadList(
                                  compact: true,
                                  cornerRadius: cornerRadius,
                                ),
                              ),
                              SizedBox(height: sectionGap),
                              Expanded(
                                child: _buildMessagesPanel(
                                  selected,
                                  compact: true,
                                  cornerRadius: cornerRadius,
                                  panelWidth: panelWidth,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              SizedBox(
                                width: threadListWidth,
                                child: _buildThreadList(
                                  compact: false,
                                  cornerRadius: cornerRadius,
                                ),
                              ),
                              SizedBox(width: sectionGap),
                              Expanded(
                                child: _buildMessagesPanel(
                                  selected,
                                  compact: false,
                                  cornerRadius: cornerRadius,
                                  panelWidth: panelWidth,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar({
    required bool compact,
    required double panelWidth,
    required double cornerRadius,
  }) {
    final iconSize = _scaleByWidth(panelWidth, min: 14, max: 16);
    final titleSize = _scaleByWidth(panelWidth, min: 12, max: 13);
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: compact ? 40 : 44),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.21),
        borderRadius: BorderRadius.vertical(top: Radius.circular(cornerRadius)),
      ),
      padding: EdgeInsets.fromLTRB(
        compact ? 8 : 10,
        compact ? 4 : 5,
        compact ? 8 : 10,
        compact ? 4 : 5,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(minHeight: compact ? 26 : 28),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 10,
            vertical: compact ? 2 : 3,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.21),
            border: Border.all(color: Colors.black.withValues(alpha: 0.7)),
            borderRadius: BorderRadius.circular(cornerRadius - 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_rounded, color: Colors.white, size: iconSize),
              const SizedBox(width: 4),
              Text(
                'All',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: titleSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThreadList({
    required bool compact,
    required double cornerRadius,
  }) {
    final results = _filteredThreads;
    final headerHeight = compact ? 44.0 : 48.0;
    final headerTitleSize = compact ? 13.0 : 14.0;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1D1C3E),
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
      child: Column(
        children: [
          Container(
            constraints: BoxConstraints(minHeight: headerHeight),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.38),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(cornerRadius),
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: compact ? 6 : 7),
            alignment: Alignment.center,
            child: Text(
              'Conversations',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: headerTitleSize,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? 10 : 12,
              compact ? 8 : 10,
              compact ? 10 : 12,
              compact ? 8 : 10,
            ),
            child: SizedBox(
              height: compact ? 34 : 36,
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 12 : 13,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.09),
                  hintText: 'Search for people',
                  hintStyle: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                    fontSize: compact ? 11 : 12,
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 30,
                    maxWidth: 34,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.white.withValues(alpha: 0.3),
                    size: compact ? 15 : 16,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: compact ? 6 : 7,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(cornerRadius - 1),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(cornerRadius - 1),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(cornerRadius - 1),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.26),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final thread = results[index];
                final selected = thread.id == _selectedThreadId;
                return _ThreadTile(
                  thread: thread,
                  compact: compact,
                  selected: selected,
                  onTap: () => _selectThread(thread.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesPanel(
    _ThreadRuntime thread, {
    required bool compact,
    required double cornerRadius,
    required double panelWidth,
  }) {
    final dayLabel = _formatDateStamp(
      thread.messages.isNotEmpty
          ? thread.messages.first.sentAt
          : DateTime.now(),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final settingsPanelWidth = (constraints.maxWidth * 0.72)
            .clamp(220.0, 340.0)
            .toDouble();
        final giftPanelWidth = (constraints.maxWidth - 16)
            .clamp(260.0, 430.0)
            .toDouble();
        final giftPanelHeight =
            (constraints.maxHeight * (compact ? 0.68 : 0.58))
                .clamp(240.0, 400.0)
                .toDouble();
        final showFloatingOverlay = _showSettingsPanel || _showGiftPanel;
        final headerHeight = compact ? 44.0 : 48.0;
        final headerTitleSize = compact ? 13.0 : 14.0;
        final headerAvatarSize = compact ? 28.0 : 30.0;
        final headerFrameSize = compact ? 34.0 : 36.0;
        final headerIconSize = _scaleByWidth(panelWidth, min: 15, max: 16);

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1D1C3E),
            borderRadius: BorderRadius.circular(cornerRadius),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    constraints: BoxConstraints(minHeight: headerHeight),
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 8 : 10,
                      vertical: compact ? 6 : 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.38),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(cornerRadius),
                      ),
                    ),
                    child: Row(
                      children: [
                        _FramedAvatar(
                          avatarAsset: thread.avatarAsset,
                          frameAsset: thread.frameAsset,
                          avatarSize: headerAvatarSize,
                          frameSize: headerFrameSize,
                          showOnlineDot: thread.isOnline,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          thread.displayName,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: headerTitleSize,
                            height: 1.3,
                          ),
                        ),
                        const Spacer(),
                        _HeaderIcon(
                          tooltip: 'Voice call',
                          icon: Icons.add_ic_call_rounded,
                          iconSize: headerIconSize,
                          onTap: () {},
                        ),
                        const SizedBox(width: 6),
                        _HeaderIcon(
                          tooltip: 'Settings',
                          icon: Icons.settings_rounded,
                          iconSize: headerIconSize,
                          onTap: _toggleSettingsPanel,
                        ),
                        const SizedBox(width: 6),
                        _HeaderIcon(
                          tooltip: 'Close',
                          icon: Icons.logout_rounded,
                          iconSize: headerIconSize,
                          onTap: () {
                            final onClose = widget.onClose;
                            if (onClose != null) {
                              onClose();
                              return;
                            }
                            Navigator.of(context).maybePop();
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        compact ? 12 : 14,
                        compact ? 10 : 12,
                        compact ? 12 : 14,
                        compact ? 10 : 12,
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView(
                              controller: _messagesController,
                              padding: const EdgeInsets.only(bottom: 8),
                              children: [
                                Center(
                                  child: Text(
                                    dayLabel,
                                    style: GoogleFonts.inter(
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                      fontWeight: FontWeight.w600,
                                      fontSize: compact ? 10 : 11,
                                    ),
                                  ),
                                ),
                                SizedBox(height: compact ? 8 : 12),
                                for (final message in thread.messages)
                                  _MessageBubble(message: message),
                              ],
                            ),
                          ),
                          SizedBox(height: compact ? 8 : 10),
                          _buildComposer(
                            thread.displayName,
                            compact: compact,
                            cornerRadius: cornerRadius,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: !showFloatingOverlay,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 120),
                    opacity: showFloatingOverlay ? 1 : 0,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _closeFloatingPanels,
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IgnorePointer(
                  ignoring: !_showSettingsPanel,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    opacity: _showSettingsPanel ? 1 : 0,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      scale: _showSettingsPanel ? 1 : 0.94,
                      alignment: Alignment.topRight,
                      child: _ChatSettingsPanel(
                        width: settingsPanelWidth,
                        notificationsEnabled: _chatOnlyNotifications,
                        onNotificationsChanged: (value) {
                          setState(() => _chatOnlyNotifications = value);
                        },
                        onClose: _closeSettingsPanel,
                        onCustomBackgroundTap: () {},
                        onMutedAccountsTap: () {},
                        onBlockedAccountsTap: () {},
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: compact ? 58 : 64,
                child: IgnorePointer(
                  ignoring: !_showGiftPanel,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    opacity: _showGiftPanel ? 1 : 0,
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      offset: _showGiftPanel
                          ? Offset.zero
                          : const Offset(0, 0.08),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: giftPanelWidth,
                          maxHeight: giftPanelHeight,
                        ),
                        child: _GiftPanel(
                          width: giftPanelWidth,
                          avatarAsset: thread.avatarAsset,
                          activeCategory: _activeGiftCategory,
                          selectedGiftId:
                              _selectedGiftId ?? _activeGiftItems.first.id,
                          multiplier: _giftMultiplier,
                          balance: _giftBalance,
                          items: _activeGiftItems,
                          onCategoryChanged: _selectGiftCategory,
                          onGiftSelected: _selectGift,
                          onCycleMultiplier: _cycleGiftMultiplier,
                          onGiftTap: _sendGift,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComposer(
    String displayName, {
    required bool compact,
    required double cornerRadius,
  }) {
    return SizedBox(
      height: compact ? 40 : 44,
      child: TextField(
        controller: _messageController,
        onSubmitted: (_) => _sendMessage(),
        style: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: compact ? 11 : 12,
        ),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: Colors.black.withValues(alpha: 0.09),
          hintText: 'Message $displayName',
          hintStyle: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
            fontSize: compact ? 10 : 11,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: compact ? 9 : 10),
          prefixIcon: Icon(
            Icons.attach_file_rounded,
            color: Colors.white.withValues(alpha: 0.74),
            size: compact ? 16 : 18,
          ),
          suffixIconConstraints: BoxConstraints(
            minWidth: compact ? 78 : 90,
            maxWidth: compact ? 88 : 98,
          ),
          suffixIcon: SizedBox(
            width: compact ? 88 : 98,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.emoji_emotions_outlined,
                  color: Colors.white.withValues(alpha: 0.54),
                  size: compact ? 18 : 20,
                ),
                SizedBox(width: compact ? 6 : 8),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _toggleGiftPanel,
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Icon(
                      Icons.card_giftcard_rounded,
                      color:
                          (_showGiftPanel
                                  ? const Color(0xFF51D76E)
                                  : Colors.white)
                              .withValues(alpha: _showGiftPanel ? 1 : 0.54),
                      size: compact ? 16 : 18,
                    ),
                  ),
                ),
                SizedBox(width: compact ? 6 : 8),
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _sendMessage,
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Icon(
                      Icons.send_rounded,
                      color: const Color(0xFF2F88FF),
                      size: compact ? 16 : 18,
                    ),
                  ),
                ),
                SizedBox(width: compact ? 6 : 8),
              ],
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(cornerRadius - 1),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(cornerRadius - 1),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(cornerRadius - 1),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.24)),
          ),
        ),
      ),
    );
  }
}

enum _GiftCategory { sweet, treasure, illusion, peeps }

class _GiftItem {
  final String id;
  final String name;
  final int price;
  final String assetPath;

  const _GiftItem({
    required this.id,
    required this.name,
    required this.price,
    required this.assetPath,
  });
}

const Map<_GiftCategory, List<_GiftItem>> _giftItemsByCategory =
    <_GiftCategory, List<_GiftItem>>{
      _GiftCategory.sweet: <_GiftItem>[
        _GiftItem(
          id: 'kiss',
          name: 'Kiss',
          price: 2,
          assetPath: 'assets/gifts/kiss.png',
        ),
        _GiftItem(
          id: 'lollipop',
          name: 'LoliPop',
          price: 5,
          assetPath: 'assets/gifts/lolipop.png',
        ),
        _GiftItem(
          id: 'kitty-paw',
          name: 'kitty paw',
          price: 5,
          assetPath: 'assets/gifts/kitty_paw.png',
        ),
        _GiftItem(
          id: 'waiby',
          name: 'Waiby',
          price: 10,
          assetPath: 'assets/gifts/waiby.png',
        ),
        _GiftItem(
          id: 'ball',
          name: 'Ball',
          price: 10,
          assetPath: 'assets/gifts/ball.png',
        ),
        _GiftItem(
          id: 'disco',
          name: 'Disco',
          price: 20,
          assetPath: 'assets/gifts/disco.png',
        ),
      ],
      _GiftCategory.treasure: <_GiftItem>[
        _GiftItem(
          id: 'kitty-paw-treasure',
          name: 'Kitty paw',
          price: 5,
          assetPath: 'assets/gifts/kitty_paw.png',
        ),
        _GiftItem(
          id: 'forever-ring',
          name: 'Forever Ring',
          price: 20,
          assetPath: 'assets/gifts/forever_ring.png',
        ),
        _GiftItem(
          id: 'cake',
          name: 'Cake',
          price: 25,
          assetPath: 'assets/gifts/cake.png',
        ),
        _GiftItem(
          id: 'magic-bell',
          name: 'Magic Bell',
          price: 50,
          assetPath: 'assets/gifts/magic_bell.png',
        ),
        _GiftItem(
          id: 'rocket',
          name: 'Rocket',
          price: 100,
          assetPath: 'assets/gifts/rocket.png',
        ),
        _GiftItem(
          id: 'party-teddy',
          name: 'Party Teddy',
          price: 150,
          assetPath: 'assets/gifts/party_teddy.png',
        ),
      ],
      _GiftCategory.illusion: <_GiftItem>[
        _GiftItem(
          id: 'big-chest',
          name: 'Big Chest',
          price: 200,
          assetPath: 'assets/gifts/big_chest.png',
        ),
        _GiftItem(
          id: 'rocket-illusion',
          name: 'Rocket',
          price: 100,
          assetPath: 'assets/gifts/rocket.png',
        ),
        _GiftItem(
          id: 'princess-treatment',
          name: 'Princess treatment',
          price: 200,
          assetPath: 'assets/gifts/princess_treatment.png',
        ),
        _GiftItem(
          id: 'wubycar',
          name: 'WubyCar',
          price: 350,
          assetPath: 'assets/gifts/wuby_car.png',
        ),
        _GiftItem(
          id: 'island',
          name: 'Island',
          price: 500,
          assetPath: 'assets/gifts/island.png',
        ),
        _GiftItem(
          id: 'dream-castle',
          name: 'Dream Castle',
          price: 1000,
          assetPath: 'assets/gifts/dream_castle.png',
        ),
      ],
      _GiftCategory.peeps: <_GiftItem>[
        _GiftItem(
          id: 'party-vibe',
          name: 'Party vibe',
          price: 20,
          assetPath: 'assets/medals/steam_pipe.png',
        ),
        _GiftItem(
          id: 'heart-cloud',
          name: 'Heart cloud',
          price: 30,
          assetPath: 'assets/medals/heartwing.png',
        ),
        _GiftItem(
          id: 'night-sigil',
          name: 'Night sigil',
          price: 40,
          assetPath: 'assets/medals/night_sigil.png',
        ),
        _GiftItem(
          id: 'gold-butterfly',
          name: 'Gold butterfly',
          price: 70,
          assetPath: 'assets/medals/goldbutterfly.png',
        ),
        _GiftItem(
          id: 'ocean-bubble',
          name: 'Ocean bubble',
          price: 80,
          assetPath: 'assets/medals/oceanbubble.png',
        ),
        _GiftItem(
          id: 'vip',
          name: 'VIP',
          price: 100,
          assetPath: 'assets/medals/vip.png',
        ),
      ],
    };

class _ThreadRuntime {
  final String id;
  final String displayName;
  final String avatarAsset;
  final String? frameAsset;
  bool previewItalic;
  String previewText;
  String lastActivityLabel;
  int unreadCount;
  bool showUnreadIndicator;
  bool isOnline;
  final List<WaibyChatMessage> messages;

  _ThreadRuntime({
    required this.id,
    required this.displayName,
    required this.avatarAsset,
    this.frameAsset,
    required this.previewItalic,
    required this.previewText,
    required this.lastActivityLabel,
    required this.unreadCount,
    required this.showUnreadIndicator,
    required this.isOnline,
    required this.messages,
  });

  factory _ThreadRuntime.fromThread(WaibyChatThread thread) {
    return _ThreadRuntime(
      id: thread.id,
      displayName: thread.displayName,
      avatarAsset: thread.avatarAsset,
      frameAsset: thread.frameAsset,
      previewItalic: thread.previewItalic,
      previewText: thread.previewText,
      lastActivityLabel: thread.lastActivityLabel,
      unreadCount: thread.unreadCount,
      showUnreadIndicator: thread.showUnreadIndicator,
      isOnline: thread.isOnline,
      messages: List<WaibyChatMessage>.from(thread.messages),
    );
  }
}

class _ThreadTile extends StatelessWidget {
  final _ThreadRuntime thread;
  final bool compact;
  final bool selected;
  final VoidCallback onTap;

  const _ThreadTile({
    required this.thread,
    required this.compact,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final showUnreadRail = selected || thread.showUnreadIndicator;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: compact ? 60 : 66),
        padding: EdgeInsets.symmetric(vertical: compact ? 6 : 8),
        color: selected
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.transparent,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (showUnreadRail) ...[
                Container(
                  width: 4,
                  height: selected ? (compact ? 12 : 14) : (compact ? 6 : 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                SizedBox(width: compact ? 6 : 8),
              ],
              _FramedAvatar(
                avatarAsset: thread.avatarAsset,
                frameAsset: thread.frameAsset,
                avatarSize: compact ? 36 : 42,
                frameSize: compact ? 44 : 50,
                unreadCount: thread.unreadCount,
              ),
              SizedBox(width: compact ? 8 : 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      thread.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: compact ? 13 : 14,
                        height: 1.25,
                      ),
                    ),
                    Text(
                      thread.previewText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                        fontSize: compact ? 11 : 12,
                        height: 1.25,
                        fontStyle: thread.previewItalic
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: compact ? 8 : 10),
              Text(
                thread.lastActivityLabel,
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 10 : 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FramedAvatar extends StatelessWidget {
  final String avatarAsset;
  final String? frameAsset;
  final double avatarSize;
  final double frameSize;
  final int unreadCount;
  final bool showOnlineDot;

  const _FramedAvatar({
    required this.avatarAsset,
    this.frameAsset,
    required this.avatarSize,
    required this.frameSize,
    this.unreadCount = 0,
    this.showOnlineDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final fallbackIconSize = math.max(16.0, avatarSize * 0.5);
    final badgeSize = math.max(16.0, avatarSize * 0.5);
    final badgeFontSize = math.max(9.0, avatarSize * 0.24);
    final onlineDotSize = math.max(12.0, avatarSize * 0.34);

    return SizedBox(
      width: frameSize,
      height: frameSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.center,
            child: ClipOval(
              child: SizedBox(
                width: avatarSize,
                height: avatarSize,
                child: Image.asset(
                  avatarAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: const Color(0xFF1B274E),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.person_rounded,
                      color: const Color(0xFF8E98B5),
                      size: fallbackIconSize,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (frameAsset != null)
            Positioned.fill(
              child: Image.asset(
                frameAsset!,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          if (unreadCount > 0)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                constraints: BoxConstraints(
                  minWidth: badgeSize,
                  minHeight: badgeSize,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: badgeSize * 0.22,
                  vertical: badgeSize * 0.12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFED4245),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF202225),
                    width: badgeSize <= 18 ? 1.4 : 1.8,
                  ),
                ),
                child: Center(
                  child: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: badgeFontSize,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          if (showOnlineDot)
            Positioned(
              right: 1,
              bottom: 2,
              child: Container(
                width: onlineDotSize,
                height: onlineDotSize,
                decoration: BoxDecoration(
                  color: const Color(0xFF51D76E),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF1D1C3E),
                    width: onlineDotSize <= 12 ? 1.4 : 1.8,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final WaibyChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final alignRight = message.fromCurrentUser;
    final maxBubbleWidth = math.min(
      340.0,
      MediaQuery.sizeOf(context).width * 0.7,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Align(
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxBubbleWidth),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: alignRight
                  ? const Color(0xFF2F88FF)
                  : const Color(0xFFADADAD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              child: Text(
                message.text,
                style: GoogleFonts.inter(
                  color: alignRight ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final double iconSize;
  final VoidCallback onTap;

  const _HeaderIcon({
    required this.tooltip,
    required this.icon,
    this.iconSize = 20,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Icon(icon, color: Colors.white, size: iconSize),
        ),
      ),
    );
  }
}

class _GiftPanel extends StatelessWidget {
  final double width;
  final String avatarAsset;
  final _GiftCategory activeCategory;
  final String selectedGiftId;
  final int multiplier;
  final double balance;
  final List<_GiftItem> items;
  final ValueChanged<_GiftCategory> onCategoryChanged;
  final ValueChanged<String> onGiftSelected;
  final VoidCallback onCycleMultiplier;
  final VoidCallback onGiftTap;

  const _GiftPanel({
    required this.width,
    required this.avatarAsset,
    required this.activeCategory,
    required this.selectedGiftId,
    required this.multiplier,
    required this.balance,
    required this.items,
    required this.onCategoryChanged,
    required this.onGiftSelected,
    required this.onCycleMultiplier,
    required this.onGiftTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final panelWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : width;
        final panelHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 420.0;
        final compact = panelWidth < 360;
        final tabsPadding = compact ? 16.0 : 22.0;
        final footerMinHeight = compact ? 64.0 : 52.0;

        return Material(
          color: Colors.transparent,
          child: Container(
            width: panelWidth,
            constraints: BoxConstraints(
              minHeight: compact ? 260 : 300,
              maxHeight: panelHeight,
            ),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(4, 6, 28, 0.88),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                  child: Row(
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: Image.asset(
                            avatarAsset,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: const Color(0xFF1B274E),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.person_rounded,
                                color: Color(0xFF8E98B5),
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(tabsPadding, 12, tabsPadding, 0),
                  child: Row(
                    children: [
                      for (final category in _GiftCategory.values)
                        Expanded(
                          child: _GiftTabButton(
                            label: _giftCategoryLabel(category),
                            active: activeCategory == category,
                            onTap: () => onCategoryChanged(category),
                            compact: compact,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: compact ? 118 : 132,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 8,
                        mainAxisExtent: compact ? 106 : 116,
                      ),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _GiftTile(
                          item: item,
                          selected: selectedGiftId == item.id,
                          onTap: () => onGiftSelected(item.id),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  constraints: BoxConstraints(minHeight: footerMinHeight),
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 12 : 16,
                    vertical: compact ? 8 : 0,
                  ),
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 0.18),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                  ),
                  child: compact
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.monetization_on_rounded,
                                  color: Color(0xFF8FBFFA),
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  balance.toStringAsFixed(2),
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Recharge',
                                  style: GoogleFonts.inter(
                                    color: const Color.fromRGBO(
                                      98,
                                      195,
                                      255,
                                      0.93,
                                    ),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _MultiplierButton(
                                  multiplier: multiplier,
                                  onTap: onCycleMultiplier,
                                  compact: true,
                                ),
                                const SizedBox(width: 8),
                                _GiftSendButton(
                                  onTap: onGiftTap,
                                  compact: true,
                                ),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            const Icon(
                              Icons.monetization_on_rounded,
                              color: Color(0xFF8FBFFA),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              balance.toStringAsFixed(2),
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Recharge',
                              style: GoogleFonts.inter(
                                color: const Color.fromRGBO(98, 195, 255, 0.93),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            _MultiplierButton(
                              multiplier: multiplier,
                              onTap: onCycleMultiplier,
                              compact: false,
                            ),
                            const SizedBox(width: 8),
                            _GiftSendButton(onTap: onGiftTap, compact: false),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GiftTabButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final bool compact;

  const _GiftTabButton({
    required this.label,
    required this.active,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: compact ? 13 : 15,
              ),
            ),
            SizedBox(height: compact ? 6 : 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: 3,
              width: compact ? 50 : 60,
              decoration: BoxDecoration(
                color: active ? const Color(0xFF51D76E) : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MultiplierButton extends StatelessWidget {
  final int multiplier;
  final VoidCallback onTap;
  final bool compact;

  const _MultiplierButton({
    required this.multiplier,
    required this.onTap,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(25),
      onTap: onTap,
      child: Container(
        height: compact ? 23 : 25,
        padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(81, 215, 110, 0.28),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Text(
              '$multiplier',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: compact ? 12 : 14,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.arrow_drop_down_rounded,
              color: const Color(0xFF51D76E),
              size: compact ? 14 : 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _GiftSendButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool compact;

  const _GiftSendButton({required this.onTap, required this.compact});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(25),
      onTap: onTap,
      child: Container(
        width: compact ? 56 : 63,
        height: compact ? 23 : 25,
        decoration: BoxDecoration(
          color: const Color(0xFF51D76E),
          borderRadius: BorderRadius.circular(25),
        ),
        alignment: Alignment.center,
        child: Text(
          'Gift',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: compact ? 12 : 14,
          ),
        ),
      ),
    );
  }
}

class _GiftTile extends StatelessWidget {
  final _GiftItem item;
  final bool selected;
  final VoidCallback onTap;

  const _GiftTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: selected
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.transparent,
          border: Border.all(
            color: selected
                ? const Color(0xFF51D76E).withValues(alpha: 0.8)
                : Colors.transparent,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Image.asset(
                  item.assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.card_giftcard_rounded,
                    color: Colors.white70,
                    size: 44,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
            Text(
              '${item.price}',
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.4),
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _giftCategoryLabel(_GiftCategory category) {
  switch (category) {
    case _GiftCategory.sweet:
      return 'Sweet';
    case _GiftCategory.treasure:
      return 'Treasure';
    case _GiftCategory.illusion:
      return 'Illusion';
    case _GiftCategory.peeps:
      return 'Peeps';
  }
}

class _ChatSettingsPanel extends StatelessWidget {
  final double width;
  final bool notificationsEnabled;
  final ValueChanged<bool> onNotificationsChanged;
  final VoidCallback onClose;
  final VoidCallback onCustomBackgroundTap;
  final VoidCallback onMutedAccountsTap;
  final VoidCallback onBlockedAccountsTap;

  const _ChatSettingsPanel({
    required this.width,
    required this.notificationsEnabled,
    required this.onNotificationsChanged,
    required this.onClose,
    required this.onCustomBackgroundTap,
    required this.onMutedAccountsTap,
    required this.onBlockedAccountsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        constraints: const BoxConstraints(minHeight: 220),
        decoration: BoxDecoration(
          color: const Color(0xFF2B2A58),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Chat settings',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFFFFDFD),
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close settings',
                    onPressed: onClose,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Enable notifications for chats only',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFFFFDFD),
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ),
                  _MiniToggle(
                    value: notificationsEnabled,
                    onChanged: onNotificationsChanged,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(
                color: Colors.white.withValues(alpha: 0.5),
                height: 1,
                thickness: 1,
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: onCustomBackgroundTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    'Custom chat background',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFFFFDFD),
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Divider(
                color: Colors.white.withValues(alpha: 0.5),
                height: 1,
                thickness: 1,
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: onMutedAccountsTap,
                child: Text(
                  'Muted accounts',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFFF0A0A),
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: onBlockedAccountsTap,
                child: Text(
                  'Blocked accounts',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFFF0A0A),
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _MiniToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: () => onChanged(!value),
      child: Container(
        width: 34,
        height: 16,
        decoration: BoxDecoration(
          color: value ? const Color(0xFF1A7B3C) : const Color(0xFF303030),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.07),
            width: 0.5,
          ),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              left: value ? 20 : 2,
              top: 2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFFECECEC),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.07),
                    width: 0.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.35),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDateStamp(DateTime value) {
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final month = months[value.month - 1];
  final day = value.day.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$month $day, ${value.year} at $hour.$minute';
}
