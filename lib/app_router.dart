import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'controllers/auth_controller.dart';
import 'shell/app_shell.dart';

import 'pages/home_page.dart';
import 'pages/explore_page.dart';
import 'pages/playground_page.dart';
import 'pages/create_room_page.dart';
import 'pages/live_room_page.dart';
import 'pages/about_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/become_creator_page.dart';
import 'pages/profile_page.dart';
import 'pages/topup_page.dart';
import 'pages/settings_page.dart';
import 'pages/creator_form.dart';
import 'pages/creator_guidelines_page.dart';
import 'pages/influencer_guidelines_page.dart';

final router = GoRouter(
  navigatorKey: Get.key,
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
          path: '/playground',
          builder: (context, state) => const PlaygroundPage(),
        ),
        GoRoute(
          path: '/playground/create-room',
          builder: (context, state) => const CreateRoomPage(),
        ),
        GoRoute(
          path: '/playground/live-room',
          builder: (context, state) {
            final role = state.uri.queryParameters['role'];
            final isHost = role == 'host';
            final visibility =
                state.uri.queryParameters['visibility'] ??
                ((state.uri.queryParameters['private'] == 'true')
                    ? 'private'
                    : 'public');
            final giftGoalBuds = double.tryParse(
              state.uri.queryParameters['giftGoalBuds'] ??
                  state.uri.queryParameters['giftGoal'] ??
                  '',
            );
            return LiveRoomPage(
              isHost: isHost,
              roomId: state.uri.queryParameters['roomId'],
              roomName: state.uri.queryParameters['roomName'],
              tagline: state.uri.queryParameters['tagline'],
              language: state.uri.queryParameters['language'],
              tags: state.uri.queryParameters['tags'],
              atmosphereImageUrl:
                  state.uri.queryParameters['atmosphereImageUrl'],
              overviewImageUrl: state.uri.queryParameters['overviewImageUrl'],
              pinnedMessage: state.uri.queryParameters['pinnedMessage'],
              visibility: visibility,
              giftGoalEnabled:
                  state.uri.queryParameters['giftGoalEnabled'] == 'true',
              giftGoalBuds: giftGoalBuds,
            );
          },
        ),
        GoRoute(path: '/pricing', redirect: (context, state) => '/playground'),
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
          path: '/wallet/topup',
          builder: (context, state) => const TopupPage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => SettingsPage(
            initialSelectedKey: state.uri.queryParameters['tab'],
          ),
        ),
        GoRoute(
          path: '/become-creator/creator-form',
          builder: (context, state) => const CreatorFormPage(),
        ),
        GoRoute(
          path: '/become-creator/creator-guidelines',
          builder: (context, state) => const CreatorGuidelinesPage(),
        ),
        GoRoute(
          path: '/settings/influencer-guidelines',
          builder: (context, state) => const InfluencerGuidelinesPage(),
        ),
      ],
    ),
  ],
);
