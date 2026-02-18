import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';

class UserMenu extends StatelessWidget {
  final AuthController auth;

  const UserMenu({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    const menuBackground = Color(0xFF0B1023);
    const menuBorderColor = Color(0xFF1A2344);
    const accentGreen = Color(0xFF51D76E);
    const destructiveRed = Color(0xFFE04B4B);
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final menuMaxWidth = math.max(240.0, math.min(320.0, viewportWidth - 32));
    final menuMinWidth = math.max(220.0, menuMaxWidth * 0.75);

    return PopupMenuButton<_UserMenuAction>(
      tooltip: "Account",
      offset: const Offset(0, 46),
      constraints: BoxConstraints(
        minWidth: menuMinWidth,
        maxWidth: menuMaxWidth,
      ),
      color: menuBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: menuBorderColor.withValues(alpha: 0.55)),
      ),
      elevation: 18,
      onSelected: (action) {
        switch (action) {
          case _UserMenuAction.myProfile:
            context.go('/profile/${Uri.encodeComponent(auth.userId)}');
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
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0E1631), Color(0xFF080C1D)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _UserAvatar(
                    photoUrl: auth.photoUrl,
                    online: auth.online.value,
                    onlineColor: accentGreen,
                    ringColor: menuBackground,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    auth.name,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${auth.userId}',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        PopupMenuItem<_UserMenuAction>(
          enabled: false,
          height: 1,
          padding: EdgeInsets.zero,
          child: Divider(
            height: 1,
            thickness: 1,
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        const PopupMenuItem<_UserMenuAction>(
          value: _UserMenuAction.myProfile,
          child: _MenuRow(icon: Icons.person_outline, text: "My profile"),
        ),
        const PopupMenuItem<_UserMenuAction>(
          value: _UserMenuAction.dashboard,
          child: _MenuRow(icon: Icons.dashboard_outlined, text: "Dashboard"),
        ),
        const PopupMenuItem<_UserMenuAction>(
          value: _UserMenuAction.wallet,
          child: _MenuRow(
            icon: Icons.account_balance_wallet_outlined,
            text: "Wallet",
          ),
        ),
        const PopupMenuItem<_UserMenuAction>(
          value: _UserMenuAction.settings,
          child: _MenuRow(icon: Icons.settings_outlined, text: "Settings"),
        ),
        PopupMenuItem<_UserMenuAction>(
          enabled: false,
          height: 1,
          padding: EdgeInsets.zero,
          child: Divider(
            height: 1,
            thickness: 1,
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        PopupMenuItem<_UserMenuAction>(
          value: _UserMenuAction.toggleOnline,
          child: _OnlineStatusRow(
            online: auth.online.value,
            onlineColor: accentGreen,
          ),
        ),
        PopupMenuItem<_UserMenuAction>(
          enabled: false,
          height: 1,
          padding: EdgeInsets.zero,
          child: Divider(
            height: 1,
            thickness: 1,
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        PopupMenuItem<_UserMenuAction>(
          value: _UserMenuAction.logout,
          child: _MenuRow(
            icon: Icons.logout,
            text: "Logout",
            color: destructiveRed,
          ),
        ),
        PopupMenuItem<_UserMenuAction>(
          value: _UserMenuAction.reportIssue,
          child: _MenuRow(
            icon: Icons.report_problem_outlined,
            text: "Report issue",
            color: destructiveRed,
          ),
        ),
      ],
      child: _AvatarCircle(
        photoUrl: auth.photoUrl,
        radius: 15,
        backgroundColor: Colors.white.withValues(alpha: 0.08),
        placeholderIconSize: 17,
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final bool online;
  final Color onlineColor;
  final Color ringColor;

  const _UserAvatar({
    required this.photoUrl,
    required this.online,
    required this.onlineColor,
    required this.ringColor,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = online ? onlineColor : Colors.grey;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        _AvatarCircle(
          photoUrl: photoUrl,
          radius: 38,
          backgroundColor: Colors.white.withValues(alpha: 0.08),
          placeholderIconSize: 38,
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(color: ringColor, shape: BoxShape.circle),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  final String? photoUrl;
  final double radius;
  final double placeholderIconSize;
  final Color backgroundColor;

  const _AvatarCircle({
    required this.photoUrl,
    required this.radius,
    required this.placeholderIconSize,
    this.backgroundColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final hasPhoto = (photoUrl ?? '').trim().isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: hasPhoto
          ? Image.network(
              photoUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.person,
                  size: placeholderIconSize,
                  color: Colors.white,
                );
              },
            )
          : Icon(Icons.person, size: placeholderIconSize, color: Colors.white),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _MenuRow({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    final foreground = color ?? Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(icon, color: foreground, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: foreground,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnlineStatusRow extends StatelessWidget {
  final bool online;
  final Color onlineColor;

  const _OnlineStatusRow({required this.online, required this.onlineColor});

  @override
  Widget build(BuildContext context) {
    final statusText = online ? "Online" : "Offline";
    final statusColor = online ? onlineColor : Colors.grey;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              statusText,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ],
      ),
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
