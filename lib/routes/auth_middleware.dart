import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../controllers/profile_controller.dart';
import '../models/user_model.dart';
import 'app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    final profileController = Get.find<ProfileController>();

    if (authService.user.value == null) {
      return const RouteSettings(name: AppRoutes.login);
    }

    final user = profileController.currentUser.value;
    if (user == null) return null; // Wait for profile to load

    if (!user.isProfileComplete && route != AppRoutes.profileSetup) {
      return const RouteSettings(name: AppRoutes.profileSetup);
    }

    // Role-based guarding
    final bool isAdmin = user.role == UserRole.admin || user.role == UserRole.superAdmin;

    // Admin pages protection
    final adminRoutes = [
      AppRoutes.adminDashboard,
      AppRoutes.adminMembers,
      AppRoutes.testUtility,
    ];

    if (adminRoutes.contains(route) && !isAdmin) {
      return const RouteSettings(name: AppRoutes.memberDashboard);
    }

    // Member dashboard protection (optional, depends if you want admins to see member view)
    if (route == AppRoutes.memberDashboard && isAdmin) {
      return const RouteSettings(name: AppRoutes.adminDashboard);
    }

    return null;
  }
}
