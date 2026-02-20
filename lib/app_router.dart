import 'package:get/get.dart';
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
import 'pages/creator_form.dart';
import 'pages/creator_guidelines_page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    // NO TOP NAVBAR HERE
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),

    // TOP NAVBAR FOR ALL ROUTES INSIDE SHELL
    ShellRoute(
      builder: (context, state, child) {
        // الحصول على AuthController من GetX
        final authController = Get.find<AuthController>();

        // لا نحتاج Obx هنا لأن AppShell ستستخدم Obx داخلياً حسب الحاجة
        return AppShell(
          // تمرير الـ controller للتوافق مع الكود القديم
          auth: authController,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            final authController = Get.find<AuthController>();
            return HomePage(auth: authController);
          },
        ),
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
          path: '/profile/:userId',
          builder: (context, state) =>
              ProfilePage(userId: state.pathParameters['userId']),
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
        GoRoute(
          path: '/become-creator/creator-form',
          builder: (context, state) => const CreatorFormPage(),
        ),
        GoRoute(
          path: '/become-creator/creator-guidelines',
          builder: (context, state) => const CreatorGuidelinesPage(),
        ),
      ],
    ),
  ],
);
