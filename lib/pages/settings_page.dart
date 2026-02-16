import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../controllers/auth_controller.dart';
import 'settings_bodies/settings_body_selector.dart';
import '../widgets/settings_sidebar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedKey = SettingsSidebarDefaults.topEntries.first.key;

  SettingsSidebarMenuEntry get _selectedEntry => SettingsSidebarDefaults
      .allEntries
      .firstWhere((entry) => entry.key == _selectedKey);

  void _onSelectTab(String key) async {
    if (key == 'logout') {
      final auth = Get.find<AuthController>();
      await auth.signOut();
      if (!mounted) {
        return;
      }
      context.go('/login');
      return;
    }

    if (_selectedKey == key) {
      return;
    }
    setState(() => _selectedKey = key);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideLayout = constraints.maxWidth >= 980;
        final sidebarWidth = constraints.maxWidth * 0.15;
        final pagePadding = isWideLayout ? 24.0 : 16.0;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0C122D), // top
                Color(0xFF050816), // bottom
              ],
            ),
          ),
          child: SafeArea(
            child: isWideLayout
                ? Row(
                    children: [
                      SizedBox(
                        width: sidebarWidth,
                        child: SettingsSidebarPanel(
                          selectedKey: _selectedKey,
                          onSelect: _onSelectTab,
                          drawRightBorder: true,
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(pagePadding),
                          child: buildSettingsBody(_selectedEntry),
                        ),
                      ),
                    ],
                  )
                : ListView(
                    padding: EdgeInsets.all(pagePadding),
                    children: [
                      SettingsSidebarPanel(
                        selectedKey: _selectedKey,
                        onSelect: _onSelectTab,
                        drawRightBorder: false,
                      ),
                      const SizedBox(height: 16),
                      buildSettingsBody(_selectedEntry),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
