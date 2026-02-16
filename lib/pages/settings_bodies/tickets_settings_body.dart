import 'package:flutter/material.dart';

import '../../widgets/settings_sidebar.dart';
import 'base_settings_body.dart';

class TicketsSettingsBody extends StatelessWidget {
  final SettingsSidebarMenuEntry entry;

  const TicketsSettingsBody({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return BaseSettingsBody(
      entry: entry,
      description: 'Monitor support tickets and configure response workflows.',
    );
  }
}
