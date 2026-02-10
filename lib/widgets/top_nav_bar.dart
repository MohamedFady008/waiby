import 'package:flutter/material.dart';
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
      _NavDestination('Playground', '/pricing'),
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
                          ? _CompactNavMenu(
                              items: navItems,
                              location: location,
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (final item in navItems) ...[
                                    _NavLink(
                                      label: item.label,
                                      isActive: _isActive(
                                        location,
                                        item.path,
                                      ),
                                      onTap: () => context.go(item.path),
                                    ),
                                    const SizedBox(width: WaibySpacing.s8),
                                  ],
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(width: WaibySpacing.s12),
                    _buildActions(
                      context,
                      compact: compact,
                      tiny: tiny,
                      accentBlue: accentBlue,
                      accentGreen: accentGreen,
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

    if (!auth.loggedIn) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!tiny) ...[
            ElevatedButton(
              onPressed: () => context.go('/become-creator'),
              style: solidButton,
              child: const Text('Become an Creator'),
            ),
            const SizedBox(width: WaibySpacing.s8),
          ],
          OutlinedButton(
            onPressed: () => context.go('/login'),
            style: solidButton.copyWith(
              backgroundColor: WidgetStateProperty.all(accentGreen),
            ),
            child: const Text('Login'),
          ),
          if (tiny) ...[
            const SizedBox(width: WaibySpacing.s8),
            _CompactActionMenu(
              onBecomeCreatorTap: () => context.go('/become-creator'),
            ),
          ],
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!compact) ...[
          ElevatedButton(
            onPressed: () => context.go('/become-creator'),
            style: solidButton,
            child: const Text('Become an Creator'),
          ),
          const SizedBox(width: WaibySpacing.s8),
        ],
        IconButton(
          tooltip: "Notifications",
          onPressed: () => context.go('/notifications'),
          icon: const Icon(Icons.notifications_none_rounded),
          color: Colors.white,
          splashRadius: 20,
          iconSize: compact ? 20 : 22,
        ),
        IconButton(
          tooltip: "Wallet top up",
          onPressed: () => context.go('/wallet/topup'),
          icon: const Icon(Icons.add_card_outlined),
          color: Colors.white,
          splashRadius: 20,
          iconSize: compact ? 20 : 22,
        ),
        if (compact) ...[
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
