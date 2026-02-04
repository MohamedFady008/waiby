import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'controllers/auth_controller.dart';
import 'shell/app_shell.dart';

import 'pages/home_page.dart';
import 'pages/explore_page.dart';
import 'pages/pricing_page.dart';
import 'pages/about_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/become_creator_page.dart';
import 'pages/profile_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/wallet_page.dart';
import 'pages/topup_page.dart';
import 'pages/settings_page.dart';
import 'pages/notifications_page.dart';
import 'pages/report_issue_page.dart';

final auth = AuthController();

final router = GoRouter(
  initialLocation: '/',
  routes: [
    // NO TOP NAVBAR HERE
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginPage(auth: auth),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => SignupPage(auth: auth),
    ),

    // TOP NAVBAR FOR ALL ROUTES INSIDE SHELL
    ShellRoute(
      builder: (context, state, child) => AnimatedBuilder(
        animation: auth,
        builder: (context, _) => AppShell(auth: auth, child: child),
      ),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomePage()),
        GoRoute(
          path: '/explore',
          builder: (context, state) => const ExplorePage(),
        ),
        GoRoute(
          path: '/pricing',
          builder: (context, state) => const PricingPage(),
        ),
        GoRoute(path: '/about', builder: (context, state) => const AboutPage()),
        GoRoute(
          path: '/become-creator',
          builder: (context, state) => const BecomeCreatorPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: '/wallet',
          builder: (context, state) => const WalletPage(),
        ),
        GoRoute(
          path: '/wallet/topup',
          builder: (context, state) => const TopupPage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsPage(),
        ),
        GoRoute(
          path: '/report',
          builder: (context, state) => const ReportIssuePage(),
        ),
      ],
    ),
  ],
);
