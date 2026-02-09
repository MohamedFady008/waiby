import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../widgets/top_nav_bar.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final AuthController auth;

  const AppShell({super.key, required this.child, required this.auth});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavBar(auth: auth),
      body: child,
    );
  }
}
