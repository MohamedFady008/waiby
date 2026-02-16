import 'package:flutter/material.dart';

import '../../widgets/settings_sidebar.dart';
import 'base_settings_body.dart';

class UnknownSettingsBody extends StatelessWidget {
  final SettingsSidebarMenuEntry entry;

  const UnknownSettingsBody({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return BaseSettingsBody(
      entry: entry,
      description: 'No body widget is mapped for this section yet.',
      statusText: 'Pending',
      statusColor: const Color(0xFFF3A712),
    );
  }
}
