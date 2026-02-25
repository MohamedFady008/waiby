import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import 'common/responsive_layout.dart';
import 'user_menu.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final AuthController auth;
  static const double _height = 72;

  const TopNavBar({super.key, required this.auth});

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    const backgroundTop = Color(0xFF0E1631);
    const backgroundBottom = Color(0xFF080C1D);
    const accentBlue = Color(0xFF2F88FF);
    const accentGreen = Color(0xFF51D76E);
    const navItems = <_NavDestination>[
      _NavDestination('Social', '/explore'),
      _NavDestination('Playground', '/playground'),
      _NavDestination('FAQ', '/about'),
    ];

    // Current location for highlighting active nav links.
    final location = GoRouterState.of(context).uri.toString();

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [backgroundTop, backgroundBottom],
          ),
          border: Border(
            bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 16,
              spreadRadius: -6,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 760;
                final tiny = constraints.maxWidth < 620;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _Logo(onTap: () => context.go('/')),
                    const SizedBox(width: WaibySpacing.s16),
                    Expanded(
                      child: compact
                          ? _CompactNavMenu(items: navItems, location: location)
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (final item in navItems) ...[
                                    _NavLink(
                                      label: item.label,
                                      isActive: _isActive(location, item.path),
                                      onTap: () => context.go(item.path),
                                    ),
                                    const SizedBox(width: WaibySpacing.s8),
                                  ],
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(width: WaibySpacing.s12),
                    Obx(
                      () => _buildActions(
                        context,
                        compact: compact,
                        tiny: tiny,
                        accentBlue: accentBlue,
                        accentGreen: accentGreen,
                        loggedIn: auth.loggedIn,
                        canShowBecomeCreator: auth.canShowBecomeCreatorButton,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(
    BuildContext context, {
    required bool compact,
    required bool tiny,
    required Color accentBlue,
    required Color accentGreen,
    required bool loggedIn,
    required bool canShowBecomeCreator,
  }) {
    final ButtonStyle solidButton = ElevatedButton.styleFrom(
      backgroundColor: accentBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 18,
        vertical: compact ? 10 : 12,
      ),
      textStyle: GoogleFonts.poppins(
        fontSize: compact ? 13 : 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );

    if (!loggedIn) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton(
            onPressed: () => context.go('/login'),
            style: solidButton.copyWith(
              backgroundColor: WidgetStateProperty.all(accentGreen),
            ),
            child: const Text('Login'),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!compact && canShowBecomeCreator) ...[
          ElevatedButton(
            onPressed: () => context.go('/become-creator'),
            style: solidButton,
            child: const Text('Become an Creator'),
          ),
          const SizedBox(width: WaibySpacing.s8),
        ],
        _NotificationsMenuButton(compact: compact),
        IconButton(
          tooltip: "Wallet top up",
          onPressed: () => context.go('/wallet/topup'),
          icon: const Icon(Icons.add_card_outlined),
          color: Colors.white,
          splashRadius: 20,
          iconSize: compact ? 20 : 22,
        ),
        if (compact && canShowBecomeCreator) ...[
          _CompactActionMenu(
            onBecomeCreatorTap: () => context.go('/become-creator'),
          ),
          const SizedBox(width: WaibySpacing.s8),
        ],
        Padding(
          padding: const EdgeInsets.only(right: WaibySpacing.s8),
          child: UserMenu(auth: auth),
        ),
      ],
    );
  }

  bool _isActive(String location, String path) {
    if (location == path) return true;
    // Treat nested paths as active (e.g. /explore/*).
    return location.startsWith('$path/') && path != '/';
  }
}

class _CompactNavMenu extends StatelessWidget {
  final List<_NavDestination> items;
  final String location;

  const _CompactNavMenu({required this.items, required this.location});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: PopupMenuButton<String>(
        tooltip: 'Navigation',
        onSelected: (path) => context.go(path),
        color: const Color(0xFF0B1023),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        itemBuilder: (context) => [
          for (final item in items)
            PopupMenuItem<String>(
              value: item.path,
              child: Text(
                item.label,
                style: GoogleFonts.poppins(
                  color: location == item.path
                      ? const Color(0xFF51D76E)
                      : Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: WaibySpacing.s12,
            vertical: WaibySpacing.s8,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.menu_rounded, color: Colors.white, size: 20),
              const SizedBox(width: WaibySpacing.s8),
              Text(
                'Menu',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactActionMenu extends StatelessWidget {
  final VoidCallback onBecomeCreatorTap;

  const _CompactActionMenu({required this.onBecomeCreatorTap});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_CompactAction>(
      tooltip: 'More actions',
      onSelected: (value) {
        if (value == _CompactAction.becomeCreator) {
          onBecomeCreatorTap();
        }
      },
      color: const Color(0xFF0B1023),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      itemBuilder: (context) => const [
        PopupMenuItem<_CompactAction>(
          value: _CompactAction.becomeCreator,
          child: Text('Become an Creator'),
        ),
      ],
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.more_horiz_rounded, color: Colors.white),
      ),
    );
  }
}

enum _CompactAction { becomeCreator }

class _NotificationsMenuButton extends StatefulWidget {
  final bool compact;

  const _NotificationsMenuButton({required this.compact});

  @override
  State<_NotificationsMenuButton> createState() =>
      _NotificationsMenuButtonState();
}

class _NotificationsMenuButtonState extends State<_NotificationsMenuButton> {
  final GlobalKey _buttonKey = GlobalKey();

  int _activeTabIndex = 0;

  late final List<_NotificationItem> _notifications = [
    _NotificationItem(
      title: 'Order Status',
      message: 'Your booking for "Valorant" has been accepted',
      timeAgo: '12h ago',
      icon: Icons.receipt_long_outlined,
      category: _NotificationCategory.orders,
    ),
    _NotificationItem(
      title: 'Refund Issued',
      message: 'A refund has been processed for Order #A19K',
      timeAgo: '12h ago',
      icon: Icons.currency_exchange_outlined,
      category: _NotificationCategory.orders,
      isUnread: false,
    ),
    _NotificationItem(
      title: 'New follower',
      message: 'Ariana followed you',
      timeAgo: '2h ago',
      icon: Icons.person_add_alt_1_rounded,
      category: _NotificationCategory.social,
    ),
    _NotificationItem(
      title: 'System Maintenance',
      message: 'Scheduled maintenance starts at 11:00 PM UTC',
      timeAgo: '1d ago',
      icon: Icons.construction_outlined,
      category: _NotificationCategory.system,
      isUnread: false,
    ),
  ];

  Future<void> _openPanel() async {
    final buttonContext = _buttonKey.currentContext;
    final overlayState = Overlay.of(context);
    final overlayBox = overlayState.context.findRenderObject() as RenderBox?;
    final buttonBox = buttonContext?.findRenderObject() as RenderBox?;

    if (overlayBox == null || buttonBox == null) return;

    final buttonBottomRight = buttonBox.localToGlobal(
      buttonBox.size.bottomRight(Offset.zero),
      ancestor: overlayBox,
    );

    final panelWidth = math.min(420.0, overlayBox.size.width - 24);
    final maxLeft = math.max(12.0, overlayBox.size.width - panelWidth - 12);
    final maxTop = math.max(12.0, overlayBox.size.height - 220);
    final panelLeft = (buttonBottomRight.dx - panelWidth).clamp(12.0, maxLeft);
    final panelTop = (buttonBottomRight.dy + 10).clamp(12.0, maxTop);

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.06),
      barrierLabel: 'Notifications',
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (dialogContext, _, _) {
        return Material(
          type: MaterialType.transparency,
          child: SafeArea(
            child: StatefulBuilder(
              builder: (dialogContext, setDialogState) {
                final tab = _NotificationCategory.values[_activeTabIndex];
                final panelHeight = math.max(
                  220.0,
                  math.min(640.0, overlayBox.size.height - panelTop - 12),
                );
                final notifications = _notifications
                    .where((item) => item.category == tab)
                    .toList(growable: false);

                return Stack(
                  children: [
                    Positioned(
                      left: panelLeft.toDouble(),
                      top: panelTop.toDouble(),
                      child: _NotificationsPanel(
                        width: panelWidth,
                        height: panelHeight,
                        activeTabIndex: _activeTabIndex,
                        unreadCounts: _unreadCounts,
                        notifications: notifications,
                        onTabSelected: (index) {
                          setState(() => _activeTabIndex = index);
                          setDialogState(() {});
                        },
                        onMarkAllRead: () {
                          setState(() {
                            for (final item in _notifications) {
                              item.isUnread = false;
                            }
                          });
                          setDialogState(() {});
                        },
                        onCheckPressed: (item) {
                          setState(() => item.isUnread = false);
                          setDialogState(() {});
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
      transitionBuilder: (_, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
            alignment: Alignment.topRight,
            child: child,
          ),
        );
      },
    );
  }

  Map<_NotificationCategory, int> get _unreadCounts {
    final counts = <_NotificationCategory, int>{
      for (final category in _NotificationCategory.values) category: 0,
    };
    for (final item in _notifications) {
      if (item.isUnread) {
        counts[item.category] = counts[item.category]! + 1;
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = _notifications.any((item) => item.isUnread);

    return IconButton(
      key: _buttonKey,
      tooltip: 'Notifications',
      onPressed: _openPanel,
      splashRadius: 20,
      color: Colors.white,
      iconSize: widget.compact ? 20 : 22,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_none_rounded),
          if (hasUnread)
            Positioned(
              right: -1,
              top: -1,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5252),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF0B1023),
                    width: 1.2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotificationsPanel extends StatelessWidget {
  final double width;
  final double height;
  final int activeTabIndex;
  final Map<_NotificationCategory, int> unreadCounts;
  final List<_NotificationItem> notifications;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onMarkAllRead;
  final ValueChanged<_NotificationItem> onCheckPressed;

  const _NotificationsPanel({
    required this.width,
    required this.height,
    required this.activeTabIndex,
    required this.unreadCounts,
    required this.notifications,
    required this.onTabSelected,
    required this.onMarkAllRead,
    required this.onCheckPressed,
  });

  @override
  Widget build(BuildContext context) {
    const panelColor = Color(0xFF030D2A);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 30,
            offset: const Offset(0, 22),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Row(
              children: [
                Text(
                  'Notifications',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: width < 440 ? 24 : 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onMarkAllRead,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2793FF),
                    textStyle: GoogleFonts.poppins(
                      fontSize: width < 440 ? 13 : 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: const Text('Mark all as read'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF151F3C),
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  for (int i = 0; i < _NotificationCategory.values.length; i++)
                    Expanded(
                      child: _NotificationTab(
                        label: _NotificationCategory.values[i].label,
                        unreadCount:
                            unreadCounts[_NotificationCategory.values[i]] ?? 0,
                        selected: i == activeTabIndex,
                        onTap: () => onTabSelected(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Text(
                      'No notifications',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: notifications.length,
                    padding: EdgeInsets.zero,
                    separatorBuilder: (_, _) => Divider(
                      color: Colors.white.withValues(alpha: 0.2),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      return _NotificationRow(
                        item: item,
                        onCheckPressed: () => onCheckPressed(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTab extends StatelessWidget {
  final String label;
  final int unreadCount;
  final bool selected;
  final VoidCallback onTap;

  const _NotificationTab({
    required this.label,
    required this.unreadCount,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = selected
        ? Colors.white
        : Colors.white.withValues(alpha: 0.9);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF253052) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  final _NotificationItem item;
  final VoidCallback onCheckPressed;

  const _NotificationRow({required this.item, required this.onCheckPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 14, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 58,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Icon(item.icon, size: 27, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  item.timeAgo,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (item.isUnread)
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF4A59),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.message,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 34,
                    child: OutlinedButton(
                      onPressed: onCheckPressed,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2E97FF),
                        side: const BorderSide(color: Color(0xFF2E97FF)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                      ),
                      child: Text(
                        'Check',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _NotificationCategory { orders, social, system }

extension on _NotificationCategory {
  String get label {
    switch (this) {
      case _NotificationCategory.orders:
        return 'Orders';
      case _NotificationCategory.social:
        return 'Social';
      case _NotificationCategory.system:
        return 'System';
    }
  }
}

class _NotificationItem {
  final String title;
  final String message;
  final String timeAgo;
  final IconData icon;
  final _NotificationCategory category;
  bool isUnread;

  _NotificationItem({
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.icon,
    required this.category,
    this.isUnread = true,
  });
}

class _Logo extends StatelessWidget {
  final VoidCallback onTap;

  const _Logo({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/logo.png', height: 40, width: 34),
          const SizedBox(width: WaibySpacing.s8),
          Text(
            'Waiby',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 24,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavLink({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.white.withValues(alpha: 0.76);
    const activeColor = Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: Colors.white.withValues(alpha: 0.08),
      highlightColor: Colors.white.withValues(alpha: 0.05),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.04),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isActive ? activeColor : baseColor,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: 15,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }
}

class _NavDestination {
  final String label;
  final String path;

  const _NavDestination(this.label, this.path);
}
