import 'package:flutter/material.dart';

import '../../data/models/chat_models.dart';
import '../../widgets/settings_sidebar.dart';
import '../../widgets/chat_window.dart';

class ChatSettingsBody extends StatelessWidget {
  final SettingsSidebarMenuEntry entry;

  const ChatSettingsBody({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportSize = MediaQuery.sizeOf(context);
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : viewportSize.width;

        final chatWidth = (availableWidth - 24).clamp(320.0, 980.0).toDouble();
        final chatHeight = (viewportSize.height - 180)
            .clamp(440.0, 860.0)
            .toDouble();

        return Center(
          child: WaibyChatWindow(
            width: chatWidth,
            height: chatHeight,
            threads: WaibyChatThread.demoThreads(),
          ),
        );
      },
    );
  }
}
