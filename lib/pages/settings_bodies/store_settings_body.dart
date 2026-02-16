import 'package:flutter/material.dart';

import '../../widgets/settings_sidebar.dart';
import 'base_settings_body.dart';

class StoreSettingsBody extends StatelessWidget {
  final SettingsSidebarMenuEntry entry;

  const StoreSettingsBody({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return BaseSettingsBody(
      entry: entry,
      description: 'Maintain store content, pricing, and listing visibility.',
    );
  }
}
