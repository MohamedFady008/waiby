import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_router.dart';
import 'controllers/auth_controller.dart';
import 'controllers/chat_controller.dart';
import 'controllers/creator_form_controller.dart';
import 'controllers/home_controller.dart';
import 'core/web/audioplayers_web_plugin_config.dart';
import 'core/web/firebase_web_loader.dart';
import 'core/web/record_web_plugin_config.dart';
import 'core/web/url_strategy_config.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    configureWebUrlStrategy();
    ensureAudioplayersWebPluginRegistered();
    ensureRecordWebPluginRegistered();

    await ensureFirebaseWebModulesLoaded();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    Get.put(AuthController(), permanent: true);
    Get.put(ChatController(), permanent: true);
    Get.lazyPut(() => CreatorFormController(), fenix: true);
    Get.lazyPut(() => HomeController(), fenix: true);
    runApp(const MyApp());
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'waiby bootstrap',
      ),
    );
    runApp(BootstrapFailureApp(error: error.toString()));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }
    if (!Get.isRegistered<ChatController>()) {
      Get.put(ChatController(), permanent: true);
    }

    return GetMaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      theme: ThemeData(useMaterial3: true),
    );
  }
}

class BootstrapFailureApp extends StatelessWidget {
  const BootstrapFailureApp({super.key, required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF050816),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1220),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Waiby could not start',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'The app hit a startup error. Refresh the page after the next deploy if this just changed.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Startup error',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        error,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
