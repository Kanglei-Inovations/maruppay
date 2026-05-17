import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/responsive_sidebar.dart';
import '../../routes/app_routes.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final profileController = Get.find<ProfileController>();
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return Scaffold(
      body: Row(
        children: [
          if (!isMobile) const MemberSidebar(activeRoute: AppRoutes.settings),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              body: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _buildProfileSection(profileController),
                      const SizedBox(height: 32),
                      _buildSection('Account'),
                      _buildTile(Icons.person_outline, 'Edit Profile', () {}),
                      _buildTile(Icons.notifications_none, 'Notifications', () {}),
                      _buildTile(Icons.security, 'Security', () {}),
                      const SizedBox(height: 24),
                      _buildSection('Support'),
                      _buildTile(Icons.help_outline, 'Help Center', () {}),
                      _buildTile(Icons.info_outline, 'About MarupX', () {}),
                      const SizedBox(height: 48),
                      ElevatedButton.icon(
                        onPressed: () => authController.logout(),
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withValues(alpha: 0.1),
                          foregroundColor: Colors.red,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(ProfileController profileController) {
    return Obx(() {
      final user = profileController.currentUser.value;
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 35, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.fullName ?? 'Member',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
