import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_controller.dart';

class UserMenu extends StatelessWidget {
  final AuthController auth;

  const UserMenu({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_UserMenuAction>(
      tooltip: "Account",
      offset: const Offset(0, 44),
      onSelected: (action) {
        switch (action) {
          case _UserMenuAction.myProfile:
            context.go('/profile');
            break;
          case _UserMenuAction.dashboard:
            context.go('/dashboard');
            break;
          case _UserMenuAction.wallet:
            context.go('/wallet');
            break;
          case _UserMenuAction.settings:
            context.go('/settings');
            break;
          case _UserMenuAction.toggleOnline:
            auth.toggleOnline();
            break;
          case _UserMenuAction.logout:
            auth.logout();
            context.go('/');
            break;
          case _UserMenuAction.reportIssue:
            context.go('/report');
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<_UserMenuAction>(
          enabled: false,
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: auth.photoUrl != null
                    ? NetworkImage(auth.photoUrl!)
                    : null,
                child: auth.photoUrl == null ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(auth.userId, style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: auth.online ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          auth.online ? "Online" : "Offline",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: _UserMenuAction.myProfile,
          child: _MenuTile(icon: Icons.person_outline, text: "My profile"),
        ),
        const PopupMenuItem(
          value: _UserMenuAction.dashboard,
          child: _MenuTile(icon: Icons.dashboard_outlined, text: "Dashboard"),
        ),
        const PopupMenuItem(
          value: _UserMenuAction.wallet,
          child: _MenuTile(
            icon: Icons.account_balance_wallet_outlined,
            text: "Wallet",
          ),
        ),
        const PopupMenuItem(
          value: _UserMenuAction.settings,
          child: _MenuTile(icon: Icons.settings_outlined, text: "Settings"),
        ),
        const PopupMenuItem(
          value: _UserMenuAction.toggleOnline,
          child: _MenuTile(
            icon: Icons.toggle_on_outlined,
            text: "Change online status",
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: _UserMenuAction.logout,
          child: _MenuTile(icon: Icons.logout, text: "Logout"),
        ),
        const PopupMenuItem(
          value: _UserMenuAction.reportIssue,
          child: _MenuTile(
            icon: Icons.report_problem_outlined,
            text: "Report issue",
          ),
        ),
      ],
      child: CircleAvatar(
        radius: 16,
        backgroundImage: auth.photoUrl != null
            ? NetworkImage(auth.photoUrl!)
            : null,
        child: auth.photoUrl == null
            ? const Icon(Icons.person, size: 18)
            : null,
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MenuTile({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(text),
    );
  }
}

enum _UserMenuAction {
  myProfile,
  dashboard,
  wallet,
  settings,
  toggleOnline,
  logout,
  reportIssue,
}
