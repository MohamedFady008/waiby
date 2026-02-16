import 'package:flutter/material.dart';

import '../../widgets/settings_sidebar.dart';
import 'base_settings_body.dart';

class CustomersSettingsBody extends StatelessWidget {
  final SettingsSidebarMenuEntry entry;

  const CustomersSettingsBody({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return BaseSettingsBody(
      entry: entry,
      description:
          'Review customer activity and relationship health in one panel.',
    );
  }
}
