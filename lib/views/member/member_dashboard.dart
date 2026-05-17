import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/wallet_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../theme/app_colors.dart';
import '../../models/wallet_model.dart';
import '../../routes/app_routes.dart';

import '../../widgets/responsive_sidebar.dart';

class MemberDashboard extends GetView<WalletController> {
  const MemberDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar for Desktop/Tablet
          if (!isMobile)
            const MemberSidebar(activeRoute: AppRoutes.memberDashboard),
          
          Expanded(
            child: CustomScrollView(
              slivers: [
                _buildAppBar(context, profileController),
                SliverPadding(
                  padding: EdgeInsets.all(isMobile ? 24 : 32),
                  sliver: SliverToBoxAdapter(
                    child: _buildWalletCard(context, controller),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: _buildSectionHeader(context, 'Your Active Marups'),
                  ),
                ),
                _buildEmptyMarups(context),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  sliver: SliverToBoxAdapter(
                    child: _buildSectionHeader(context, 'Recent Activity'),
                  ),
                ),
                _buildTransactionList(controller),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isMobile ? _buildBottomNav(context) : null,
    );
  }

  Widget _buildAppBar(BuildContext context, ProfileController profileController) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    return SliverAppBar(
      expandedHeight: isMobile ? 140 : 80,
      floating: true,
      pinned: true,
      backgroundColor: Colors.black,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.symmetric(horizontal: 24, vertical: isMobile ? 16 : 20),
        centerTitle: !isMobile,
        title: Obx(() => Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isMobile) const Text('Welcome back,', style: TextStyle(color: Colors.white54, fontSize: 12)),
            Text(
              isMobile 
                ? (profileController.currentUser.value?.fullName ?? 'Member')
                : 'Dashboard Overview',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        )),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_outlined, color: Colors.white),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () {},
          child: const Text('View All', style: TextStyle(color: AppColors.primary)),
        ),
      ],
    );
  }

  Widget _buildWalletCard(BuildContext context, WalletController controller) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    return Container(
      constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 600),
      padding: EdgeInsets.all(isMobile ? 28 : 40),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Wallet Balance', 
                style: TextStyle(color: Colors.white70, fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.w500)),
              InkWell(
                onTap: () => Get.toNamed(AppRoutes.wallet),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() => Text(
            '₹${controller.wallet.value?.balance.toStringAsFixed(2) ?? '0.00'}',
            style: TextStyle(color: Colors.white, fontSize: isMobile ? 38 : 48, fontWeight: FontWeight.bold, letterSpacing: -1),
          )),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildWalletAction(
                  icon: Icons.add_rounded,
                  label: 'Add Funds',
                  onTap: () => _showAddMoneyDialog(context, controller),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildWalletAction(
                  icon: Icons.send_rounded,
                  label: 'Pay Marup',
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.1);
  }

  Widget _buildWalletAction({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMarups(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 180,
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.layers_clear_outlined, size: 40, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text('No active Marup groups found', style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {},
              child: const Text('Browse Groups', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(WalletController controller) {
    return Obx(() => SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final tx = controller.transactions[index];
          final isCredit = tx.type == TransactionType.deposit || tx.type == TransactionType.winning;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCredit ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                    color: isCredit ? Colors.green : Colors.red,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tx.description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM dd • hh:mm a').format(tx.timestamp),
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${isCredit ? '+' : '-'} ₹${tx.amount}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isCredit ? Colors.green : Colors.white,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.05);
        },
        childCount: controller.transactions.length,
      ),
    ));
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        border: const Border(top: BorderSide(color: Colors.white10)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(Icons.home_filled, 'Home', true, () {}),
            _buildNavItem(Icons.account_balance_wallet_outlined, 'Wallet', false, () => Get.toNamed(AppRoutes.wallet)),
            _buildNavItem(Icons.stars_outlined, 'Lottery', false, () => Get.toNamed(AppRoutes.lottery)),
            _buildNavItem(Icons.settings_outlined, 'Settings', false, () => Get.toNamed(AppRoutes.settings)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? AppColors.primary : Colors.white38, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isActive ? AppColors.primary : Colors.white38, fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  void _showAddMoneyDialog(BuildContext context, WalletController controller) {
    final amountController = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Add Money', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: amountController,
          autofocus: true,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixText: '₹ ',
            hintText: '0.00',
            hintStyle: TextStyle(color: Colors.white12),
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                controller.addBalance(amount);
                Get.back();
              }
            },
            child: const Text('Add Now'),
          ),
        ],
      ),
    );
  }
}
