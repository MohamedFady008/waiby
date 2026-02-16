import 'package:flutter/material.dart';

import '../../widgets/settings_sidebar.dart';
import 'base_settings_body.dart';

class RankingsSettingsBody extends StatelessWidget {
  final SettingsSidebarMenuEntry entry;

  const RankingsSettingsBody({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return BaseSettingsBody(
      entry: entry,
      description: 'Review ranking logic and measure progress over time.',
    );
  }
}
