import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'core/initial_binding.dart';
import 'firebase_options.dart';
import 'models/user_model.dart';

void main() async {
  // 1. Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }

  // 3. Dynamic Initial Routing (WhatsApp Style)
  String initialRoute = AppRoutes.initial; // Default to Splash
  
  try {
    // Warm up SharedPreferences channel
    final prefs = await SharedPreferences.getInstance();
    final isComplete = prefs.getBool('is_profile_complete') ?? false;
    final cachedRole = prefs.getString('user_role');
    
    // Check if Firebase session is already active
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      if (isComplete && cachedRole != null) {
        // Instant redirection if cache exists
        if (cachedRole == UserRole.admin.name || cachedRole == UserRole.superAdmin.name) {
          initialRoute = AppRoutes.adminDashboard;
        } else {
          initialRoute = AppRoutes.memberDashboard;
        }
      } else {
        // User logged in but profile not complete
        initialRoute = AppRoutes.profileSetup;
      }
    } else {
      // Not logged in
      initialRoute = AppRoutes.login;
    }
  } catch (e) {
    debugPrint('Channel initialization failed (Normal during Hot Restart after plugin add): $e');
    // Fallback to Splash logic
    initialRoute = AppRoutes.initial;
  }

  runApp(MarupXApp(initialRoute: initialRoute));
}

class MarupXApp extends StatelessWidget {
  final String initialRoute;
  const MarupXApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MarupPay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),

      initialRoute: initialRoute,
      getPages: AppRoutes.routes,
      initialBinding: InitialBinding(),
      defaultTransition: Transition.cupertino,
    );
  }
}
