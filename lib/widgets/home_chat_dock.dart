import 'dart:math' as math;

import 'package:flutter/material.dart';

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
  late final List<WaibyChatThread> _threads;
  String? _activeThreadId;

  @override
  void initState() {
    super.initState();
    _threads = _resolveThreads();
  }

  List<WaibyChatThread> _resolveThreads() {
    final provided = widget.threads;
    if (provided == null || provided.isEmpty) {
      return WaibyChatThread.demoThreads();
    }
    return provided.toList(growable: false);
  }

  bool get _panelOpen => _activeThreadId != null;

  void _openThread(String threadId) {
    setState(() => _activeThreadId = threadId);
  }

  void _closePanel() {
    setState(() => _activeThreadId = null);
  }

  @override
  Widget build(BuildContext context) {
    final sidebarItems = _threads
        .map(
          (thread) => ChatSidebarItem(
            avatarAsset: thread.avatarAsset,
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
        final visiblePanelWidth = _panelOpen ? maxPanelWidth : 0.0;

        return Stack(
          children: [
            if (_panelOpen)
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
                            ignoring: !_panelOpen,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOut,
                              opacity: _panelOpen ? 1 : 0,
                              child: AnimatedSlide(
                                duration: const Duration(milliseconds: 340),
                                curve: Curves.easeOutCubic,
                                offset: _panelOpen
                                    ? Offset.zero
                                    : const Offset(0.08, 0),
                                child: WaibyChatWindow(
                                  width: maxPanelWidth,
                                  height: dockHeight,
                                  threads: _threads,
                                  initialThreadId: _activeThreadId,
                                  onClose: _closePanel,
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
                    offset: _panelOpen ? const Offset(-0.02, 0) : Offset.zero,
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
}
