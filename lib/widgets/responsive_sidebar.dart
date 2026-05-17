import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../routes/app_routes.dart';

class MemberSidebar extends StatelessWidget {
  final String activeRoute;
  const MemberSidebar({super.key, this.activeRoute = AppRoutes.memberDashboard});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final profileController = Get.find<ProfileController>();
    
    return Container(
      width: 280,
      color: AppColors.cardBg,
      child: Column(
        children: [
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.account_balance_wallet, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                const Text('MarupX', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 48),
          _SidebarItem(
            icon: Icons.home_filled, 
            label: 'Home', 
            isActive: activeRoute == AppRoutes.memberDashboard, 
            onTap: () => _navigate(AppRoutes.memberDashboard),
          ),
          _SidebarItem(
            icon: Icons.account_balance_wallet, 
            label: 'Wallet', 
            isActive: activeRoute == AppRoutes.wallet,
            onTap: () => _navigate(AppRoutes.wallet),
          ),
          _SidebarItem(
            icon: Icons.stars, 
            label: 'Draws', 
            isActive: activeRoute == AppRoutes.lottery,
            onTap: () => _navigate(AppRoutes.lottery),
          ),
          _SidebarItem(
            icon: Icons.settings, 
            label: 'Settings', 
            isActive: activeRoute == AppRoutes.settings,
            onTap: () => _navigate(AppRoutes.settings),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Obx(() {
              final user = profileController.currentUser.value;
              return Row(
                children: [
                  const CircleAvatar(radius: 20, backgroundColor: AppColors.primary, child: Icon(Icons.person, color: Colors.white, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.fullName ?? 'Member', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(user?.email ?? '', style: TextStyle(color: AppColors.textMuted, fontSize: 10), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
          _SidebarItem(
            icon: Icons.logout, 
            label: 'Logout', 
            onTap: () => authController.logout(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _navigate(String route) {
    if (Get.currentRoute == route) return;
    Get.offAllNamed(route);
  }
}

class AdminSidebar extends StatelessWidget {
  final String activeRoute;
  const AdminSidebar({super.key, this.activeRoute = AppRoutes.adminDashboard});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    return Container(
      width: 280,
      color: AppColors.cardBg,
      child: Column(
        children: [
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.account_balance_wallet, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                const Text('MarupX Admin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 48),
          _SidebarItem(
            icon: Icons.dashboard, 
            label: 'Overview', 
            isActive: activeRoute == AppRoutes.adminDashboard,
            onTap: () => _navigate(AppRoutes.adminDashboard),
          ),
          _SidebarItem(icon: Icons.group_work, label: 'Manage Groups'),
          _SidebarItem(icon: Icons.people, label: 'User Directory'),
          _SidebarItem(icon: Icons.account_balance, label: 'Financials'),
          _SidebarItem(icon: Icons.analytics, label: 'Reporting'),
          _SidebarItem(icon: Icons.notifications, label: 'Broadcaster'),
          const Spacer(),
          _SidebarItem(
            icon: Icons.logout, 
            label: 'Logout', 
            onTap: () => authController.logout(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _navigate(String route) {
    if (Get.currentRoute == route) return;
    Get.offAllNamed(route);
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _SidebarItem({required this.icon, required this.label, this.isActive = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? AppColors.primary : AppColors.textMuted),
        title: Text(label, style: TextStyle(
          color: isActive ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        )),
        onTap: onTap ?? () {},
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
