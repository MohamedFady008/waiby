import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_router.dart';
import 'controllers/auth_controller.dart';
import 'controllers/creator_form_controller.dart';
import 'controllers/home_controller.dart';
import 'core/web/firebase_web_loader.dart';
import 'core/web/url_strategy_config.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureWebUrlStrategy();

  await ensureFirebaseWebModulesLoaded();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put(AuthController(), permanent: true);
  Get.lazyPut(() => CreatorFormController(), fenix: true);
  Get.lazyPut(() => HomeController(), fenix: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
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
