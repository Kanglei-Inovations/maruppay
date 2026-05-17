import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'core/initial_binding.dart';
import 'firebase_options.dart';

void main() async {
  // 1. Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase with explicit options to resolve channel-error
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully with options');
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }

  runApp(const MarupXApp());
}

class MarupXApp extends StatelessWidget {
  const MarupXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MarupPay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      getPages: AppRoutes.routes,
      initialBinding: InitialBinding(),
      defaultTransition: Transition.cupertino,
    );
  }
}
