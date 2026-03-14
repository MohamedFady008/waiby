import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../controllers/auth_controller.dart';
import '../controllers/chat_controller.dart';
import '../widgets/home_chat_dock.dart';
import '../widgets/top_nav_bar.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final AuthController auth;

  const AppShell({super.key, required this.child, required this.auth});

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final chatController = Get.find<ChatController>();
    chatController.handleRouteChanged(path);
    final minWidth = _chatDockMinWidthForPath(path);
    if (minWidth == null) {
      return Scaffold(
        appBar: TopNavBar(auth: auth),
        body: child,
      );
    }

    return Scaffold(
      appBar: TopNavBar(auth: auth),
      body: LayoutBuilder(
        builder: (context, constraints) {
          const sidebarWidth = WaibyHomeChatDock.defaultSidebarWidth;
          const sidebarGap = WaibyHomeChatDock.defaultSidebarGap;
          final showChatDockByWidth = constraints.maxWidth >= minWidth;

          return Obx(() {
            final isLoggedIn = auth.currentUser.value != null;
            final showChatDock = isLoggedIn && showChatDockByWidth;

            return Stack(
              children: [
                child,
                if (showChatDock)
                  Positioned.fill(
                    child: WaibyHomeChatDock(
                      key: ValueKey<String>('chat-dock:$path'),
                      sidebarWidth: sidebarWidth,
                      sidebarGap: sidebarGap,
                    ),
                  ),
              ],
            );
          });
        },
      ),
    );
  }
}

double? _chatDockMinWidthForPath(String path) {
  if (path == '/') return 1000;
  if (path == '/explore') return 1000;
  if (path == '/playground') return 1000;
  if (path == '/playground/create-room') return 1000;
  if (path == '/playground/live-room') return 1000;
  if (path == '/about') return 1000;
  if (path == '/wallet/topup') return 1000;
  if (path == '/profile' || path.startsWith('/profile/')) return 1000;
  return null;
}
