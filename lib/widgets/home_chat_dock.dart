import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../controllers/chat_controller.dart';
import '../data/models/chat_models.dart';
import 'chat_sidebar.dart';
import 'chat_window.dart';

class WaibyHomeChatDock extends StatefulWidget {
  static const double defaultSidebarWidth = ChatSidebar.contentRailWidth;
  static const double defaultSidebarGap = 12;

  final double sidebarWidth;
  final double sidebarGap;
  final List<WaibyChatThread>? threads;

  const WaibyHomeChatDock({
    super.key,
    this.sidebarWidth = defaultSidebarWidth,
    this.sidebarGap = defaultSidebarGap,
    this.threads,
  });

  @override
  State<WaibyHomeChatDock> createState() => _WaibyHomeChatDockState();
}

class _WaibyHomeChatDockState extends State<WaibyHomeChatDock> {
  late final List<WaibyChatThread> _providedThreads;
  String? _providedActiveThreadId;
  late final ChatController _chatController;

  bool get _usesProvidedThreads => widget.threads != null;

  @override
  void initState() {
    super.initState();
    _providedThreads = _resolveThreads();
    _chatController = Get.find<ChatController>();
  }

  List<WaibyChatThread> _resolveThreads() {
    final provided = widget.threads;
    if (provided == null) {
      return const <WaibyChatThread>[];
    }
    if (provided.isEmpty) {
      return WaibyChatThread.demoThreads();
    }
    return provided.toList(growable: false);
  }

  void _openThread(String threadId) {
    if (_usesProvidedThreads) {
      setState(() => _providedActiveThreadId = threadId);
      return;
    }
    _chatController.selectThread(threadId);
  }

  void _closePanel() {
    if (_usesProvidedThreads) {
      setState(() => _providedActiveThreadId = null);
      return;
    }
    _chatController.closePanel();
  }

  Future<void> _sendMessage(String threadId, String message) {
    if (_usesProvidedThreads) {
      return Future<void>.value();
    }
    return _chatController.sendMessage(threadId: threadId, text: message);
  }

  Future<double?> _sendGift(String threadId, WaibyChatGift gift) {
    if (_usesProvidedThreads) {
      return Future<double?>.value(null);
    }
    return _chatController.sendGift(threadId: threadId, gift: gift);
  }

  Widget _buildDock({
    required List<WaibyChatThread> threads,
    required String? activeThreadId,
  }) {
    final panelOpen =
        activeThreadId != null &&
        threads.any((thread) => thread.id == activeThreadId);
    final sidebarItems = threads
        .map(
          (thread) => ChatSidebarItem(
            avatarAsset: thread.avatarAsset,
            avatarUrl: thread.avatarUrl,
            frameAsset: thread.frameAsset,
            unreadCount: thread.unreadCount,
            showUnreadIndicator: thread.showUnreadIndicator,
            onTap: () => _openThread(thread.id),
          ),
        )
        .toList(growable: false);

    return LayoutBuilder(
      builder: (context, constraints) {
        final dockHeight = math.max(320.0, constraints.maxHeight - 0);
        final rawPanelWidth =
            constraints.maxWidth - widget.sidebarWidth - widget.sidebarGap - 24;
        final maxPanelWidth = rawPanelWidth.clamp(520.0, 860.0).toDouble();
        final visiblePanelWidth = panelOpen ? maxPanelWidth : 0.0;

        return Stack(
          children: [
            if (panelOpen)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _closePanel,
                ),
              ),
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 340),
                    curve: Curves.easeOutCubic,
                    width: visiblePanelWidth,
                    height: dockHeight,
                    child: ClipRect(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: maxPanelWidth,
                          height: dockHeight,
                          child: IgnorePointer(
                            ignoring: !panelOpen,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOut,
                              opacity: panelOpen ? 1 : 0,
                              child: AnimatedSlide(
                                duration: const Duration(milliseconds: 340),
                                curve: Curves.easeOutCubic,
                                offset: panelOpen
                                    ? Offset.zero
                                    : const Offset(0.08, 0),
                                child: WaibyChatWindow(
                                  width: maxPanelWidth,
                                  height: dockHeight,
                                  threads: threads,
                                  budsBalance: _usesProvidedThreads
                                      ? 0
                                      : _chatController.budsBalance.value,
                                  initialThreadId: activeThreadId,
                                  onClose: _closePanel,
                                  onThreadSelected: _usesProvidedThreads
                                      ? null
                                      : _chatController.selectThread,
                                  onSendMessage: _usesProvidedThreads
                                      ? null
                                      : _sendMessage,
                                  onSendGift: _usesProvidedThreads
                                      ? null
                                      : _sendGift,
                                  onRechargeTap: _usesProvidedThreads
                                      ? null
                                      : () => context.go('/wallet/topup'),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: widget.sidebarGap),
                  AnimatedSlide(
                    duration: const Duration(milliseconds: 340),
                    curve: Curves.easeOutCubic,
                    offset: panelOpen ? const Offset(-0.02, 0) : Offset.zero,
                    child: SizedBox(
                      width: widget.sidebarWidth,
                      height: dockHeight,
                      child: ChatSidebar(
                        width: widget.sidebarWidth,
                        items: sidebarItems,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_usesProvidedThreads) {
      return _buildDock(
        threads: _providedThreads,
        activeThreadId: _providedActiveThreadId,
      );
    }
    return Obx(() {
      return _buildDock(
        threads: _chatController.threads.toList(growable: false),
        activeThreadId: _chatController.activeThreadId.value,
      );
    });
  }
}
