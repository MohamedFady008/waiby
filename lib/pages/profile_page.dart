import 'package:flutter/material.dart';

import '../widgets/simple_text_page.dart';

class ProfilePage extends StatelessWidget {
  final String? userId;

  const ProfilePage({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    final resolvedUser = userId?.trim();
    if (resolvedUser == null || resolvedUser.isEmpty) {
      return const SimpleTextPage(text: 'My Profile');
    }
    return SimpleTextPage(text: 'Profile: $resolvedUser');
  }
}
