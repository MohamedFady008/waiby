import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_router.dart';
import 'controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Supabase
  await Supabase.initialize(
    url: 'https://oszuukbnfgcnzmjlzvox.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9zenV1a2JuZmdjbnptamx6dm94Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA1NDA5OTcsImV4cCI6MjA4NjExNjk5N30.CYcH4Wt_nqTv44I2UupWTHJdmyid_bic51t4l675K8A',
  );

  // تسجيل AuthController كـ GetX dependency
  Get.put(AuthController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      theme: ThemeData(useMaterial3: true),
    );
  }
}
