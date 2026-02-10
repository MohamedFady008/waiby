import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class ChatSidebarItem {
  final String avatarAsset;
  final String? frameAsset;
  final int unreadCount;
  final bool showUnreadIndicator;
  final VoidCallback? onTap;

  const ChatSidebarItem({
    required this.avatarAsset,
    this.frameAsset,
    this.unreadCount = 0,
    this.showUnreadIndicator = false,
    this.onTap,
  });
}

class ChatSidebar extends StatelessWidget {
  static const List<ChatSidebarItem> defaultItems = <ChatSidebarItem>[
    ChatSidebarItem(
      avatarAsset: 'assets/pp1.png',
      frameAsset: 'assets/medals/vine_wreath.png',
      unreadCount: 1,
      showUnreadIndicator: true,
    ),
    ChatSidebarItem(
      avatarAsset: 'assets/pp2.png',
      frameAsset: 'assets/medals/kittybloom.png',
    ),
    ChatSidebarItem(avatarAsset: 'assets/pp3.png'),
    ChatSidebarItem(
      avatarAsset: 'assets/pp4.png',
      frameAsset: 'assets/medals/golden.png',
      unreadCount: 1,
      showUnreadIndicator: true,
    ),
    ChatSidebarItem(
      avatarAsset: 'assets/pp5.png',
      unreadCount: 1,
      showUnreadIndicator: true,
    ),
    ChatSidebarItem(
      avatarAsset: 'assets/pp6.png',
      frameAsset: 'assets/medals/lolita_pearl.png',
      unreadCount: 1,
      showUnreadIndicator: true,
    ),
    ChatSidebarItem(
      avatarAsset: 'assets/pp7.png',
      frameAsset: 'assets/medals/aqua_ring.png',
    ),
    ChatSidebarItem(
      avatarAsset: 'assets/pp2.png',
      frameAsset: 'assets/medals/lolita_pearl.png',
    ),
    ChatSidebarItem(
      avatarAsset: 'assets/pp6.png',
      frameAsset: 'assets/medals/vine_wreath.png',
    ),
    ChatSidebarItem(
      avatarAsset: 'assets/pp5.png',
      frameAsset: 'assets/medals/aurealux_emblem.png',
    ),
  ];

  final List<ChatSidebarItem> items;
  final double width;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final double avatarSize;
  final double frameSize;
  final double itemSpacing;
  final double unreadBadgeSize;
  final double unreadBadgeFontSize;

  const ChatSidebar({
    super.key,
    this.items = defaultItems,
    this.width = 76,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
    this.backgroundColor = const Color.fromRGBO(255, 255, 255, 0.08),
    this.avatarSize = 48,
    this.frameSize = 66,
    this.itemSpacing = 18,
    this.unreadBadgeSize = 30,
    this.unreadBadgeFontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final railWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : width;
        final resolvedFrameSize = math
            .min(frameSize, railWidth - 8)
            .clamp(54.0, frameSize)
            .toDouble();
        final resolvedAvatarSize = math
            .min(avatarSize, resolvedFrameSize - 12)
            .clamp(40.0, avatarSize)
            .toDouble();
        final resolvedSpacing = railWidth < 72 ? 12.0 : itemSpacing;

        return Container(
          color: backgroundColor,
          child: ListView.separated(
            padding: padding,
            itemCount: items.length,
            separatorBuilder: (_, _) => SizedBox(height: resolvedSpacing),
            itemBuilder: (context, index) => _ChatSidebarTile(
              item: items[index],
              avatarSize: resolvedAvatarSize,
              frameSize: resolvedFrameSize,
              unreadBadgeSize: unreadBadgeSize,
              unreadBadgeFontSize: unreadBadgeFontSize,
            ),
          ),
        );
      },
    );
  }
}

class _ChatSidebarTile extends StatelessWidget {
  final ChatSidebarItem item;
  final double avatarSize;
  final double frameSize;
  final double unreadBadgeSize;
  final double unreadBadgeFontSize;

  const _ChatSidebarTile({
    required this.item,
    required this.avatarSize,
    required this.frameSize,
    required this.unreadBadgeSize,
    required this.unreadBadgeFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: frameSize + 4,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (item.showUnreadIndicator)
            Positioned(
              left: 0,
              child: Container(
                width: 4,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: item.onTap,
              customBorder: const CircleBorder(),
              child: SizedBox(
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
                            item.avatarAsset,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: const Color(0xFF1B274E),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.person_rounded,
                                color: Color(0xFF8E98B5),
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (item.frameAsset != null)
                      Positioned.fill(
                        child: Image.asset(
                          item.frameAsset!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ),
                    if (item.unreadCount > 0)
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: _UnreadBadge(
                          count: item.unreadCount,
                          size: unreadBadgeSize,
                          fontSize: unreadBadgeFontSize,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  final int count;
  final double size;
  final double fontSize;

  const _UnreadBadge({
    required this.count,
    required this.size,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final text = count > 99 ? '99+' : '$count';
    final borderWidth = size <= 22 ? 1.4 : 2.0;
    return Container(
      constraints: BoxConstraints(minWidth: size, minHeight: size),
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.24,
        vertical: size * 0.16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFED4245),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF202225), width: borderWidth),
      ),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: fontSize,
            letterSpacing: -0.2,
            height: 1,
          ),
        ),
      ),
    );
  }
}
