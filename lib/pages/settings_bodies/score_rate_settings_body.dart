import 'package:flutter/material.dart';

import '../../widgets/settings_sidebar.dart';
import 'base_settings_body.dart';

class ScoreRateSettingsBody extends StatelessWidget {
  final SettingsSidebarMenuEntry entry;

  const ScoreRateSettingsBody({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return BaseSettingsBody(
      entry: entry,
      description: 'Define score rates and evaluate performance weighting.',
    );
  }
}
