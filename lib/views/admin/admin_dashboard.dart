import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/group_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/admin/create_group_dialog.dart';
import '../../widgets/admin/group_list.dart';

class AdminDashboard extends GetView<GroupController> {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => authController.logout(),
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsOverview(),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Marup Groups', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: () => Get.dialog(const CreateGroupDialog()),
                  icon: const Icon(Icons.add),
                  label: const Text('Create New'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return GroupList(groups: controller.groups);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppColors.primary),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.admin_panel_settings, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text('Admin Management', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_rounded),
            title: const Text('Dashboard'),
            onTap: () => Get.back(),
          ),
          ListTile(
            leading: const Icon(Icons.group_rounded),
            title: const Text('Manage Members'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_rounded),
            title: const Text('Wallet Balances'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_rounded),
            title: const Text('Transactions'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.stars_rounded),
            title: const Text('Winners'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Obx(() => GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _statCard('Total Groups', controller.totalGroups.toString(), Colors.blue),
        _statCard('Active Marups', controller.activeGroups.toString(), Colors.green),
        _statCard('Total Collection', '₹${controller.totalCollection.toStringAsFixed(0)}', Colors.orange),
        _statCard('Total Members', '0', Colors.purple),
      ],
    ));
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
