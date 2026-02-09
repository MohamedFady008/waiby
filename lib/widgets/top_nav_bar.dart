import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import 'user_menu.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final AuthController auth;

  const TopNavBar({super.key, required this.auth});

  @override
  Size get preferredSize => const Size.fromHeight(88);

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
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: preferredSize.height),
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
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _Logo(onTap: () => context.go('/')),
                    const SizedBox(width: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final item in navItems) ...[
                              _NavLink(
                                label: item.label,
                                isActive: _isActive(location, item.path),
                                onTap: () => context.go(item.path),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildActions(
                      context,
                      accentBlue: accentBlue,
                      accentGreen: accentGreen,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(
    BuildContext context, {
    required Color accentBlue,
    required Color accentGreen,
  }) {
    final ButtonStyle solidButton = ElevatedButton.styleFrom(
      backgroundColor: accentBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      textStyle: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );

    if (!auth.loggedIn) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () => context.go('/become-creator'),
            style: solidButton,
            child: const Text('Become an Creator'),
          ),
          const SizedBox(width: 10),
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
        const SizedBox(width: 6),
        ElevatedButton(
          onPressed: () => context.go('/become-creator'),
          style: solidButton,
          child: const Text('Become an Creator'),
        ),
        const SizedBox(width: 6),
        IconButton(
          tooltip: "Notifications",
          onPressed: () => context.go('/notifications'),
          icon: const Icon(Icons.notifications_none_rounded),
          color: Colors.white,
          splashRadius: 24,
        ),
        IconButton(
          tooltip: "Wallet top up",
          onPressed: () => context.go('/wallet/topup'),
          icon: const Icon(Icons.add_card_outlined),
          color: Colors.white,
          splashRadius: 24,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
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
          Image.asset('assets/logo.png', height: 44, width: 38),
          const SizedBox(width: 10),
          Text(
            'Waiby',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 28,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            fontSize: 16,
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
