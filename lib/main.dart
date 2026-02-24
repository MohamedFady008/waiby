import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_router.dart';
import 'controllers/auth_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Fonts are not bundled locally in this project, so keep runtime fetch on.
  GoogleFonts.config.allowRuntimeFetching = true;

  // Keep Firestore cache usable when connection is unstable.
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (_) {
    // Ignore when settings cannot be changed on hot restarts.
  }

  Get.put(AuthController(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (!GoogleFonts.config.allowRuntimeFetching) {
      GoogleFonts.config.allowRuntimeFetching = true;
    }

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
