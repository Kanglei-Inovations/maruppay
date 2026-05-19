import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/wallet_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../theme/app_colors.dart';
import '../../models/wallet_model.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final walletController = Get.find<WalletController>();
    final profileController = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Account & Settings', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(profileController),
            const SizedBox(height: 32),
            
            _buildSectionTitle('PREFERENCES'),
            const SizedBox(height: 12),
            _buildSettingTile(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              trailing: Switch(
                value: isDarkMode,
                onChanged: (v) {
                  setState(() => isDarkMode = v);
                  Get.changeTheme(v ? ThemeData.dark() : ThemeData.light());
                },
                activeColor: AppColors.primary,
              ),
            ),
            
            const SizedBox(height: 32),
            _buildSectionTitle('WALLET ACTIVITY'),
            const SizedBox(height: 12),
            _buildWalletHistory(walletController),
            
            const SizedBox(height: 32),
            _buildSectionTitle('COMMUNITY'),
            const SizedBox(height: 12),
            _buildSettingTile(
              icon: Icons.share_outlined,
              title: 'Invite Friends',
              onTap: () => Get.snackbar('Invite', 'Referral link copied!', snackPosition: SnackPosition.BOTTOM),
            ),
            _buildSettingTile(
              icon: Icons.gavel_outlined,
              title: 'Marup Rules',
              onTap: () => _showRulesDialog(context),
            ),
            
            const SizedBox(height: 40),
            _buildLogoutButton(authController),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 11),
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
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white10,
              child: Icon(Icons.person, color: AppColors.gold, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.fullName ?? 'Member', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(user?.mobileNumber ?? 'N/A', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  const SizedBox(height: 4),
                  _buildKYCBadge(user?.kycStatus ?? 'pending'),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildKYCBadge(String status) {
    final isVerified = status == 'verified';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (isVerified ? AppColors.primary : AppColors.gold).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isVerified ? AppColors.primary : AppColors.gold, width: 0.5),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: isVerified ? AppColors.primary : AppColors.gold, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSettingTile({required IconData icon, required String title, Widget? trailing, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.textMuted, size: 22),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
      ),
    );
  }

  Widget _buildWalletHistory(WalletController walletController) {
    return Obx(() {
      final txs = walletController.transactions.take(5).toList();
      if (txs.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
          child: const Center(child: Text('No recent activity', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
        );
      }
      return Column(
        children: txs.map((tx) {
          final isCredit = tx.type == TransactionType.deposit || tx.type == TransactionType.winning;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Icon(isCredit ? Icons.add_circle : Icons.remove_circle, color: isCredit ? AppColors.primary : Colors.redAccent, size: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tx.description, style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold)),
                      Text(DateFormat('dd MMM, hh:mm a').format(tx.timestamp), style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                Text('${isCredit ? '+' : '-'}₹${tx.amount}', style: TextStyle(color: isCredit ? Colors.green : Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildLogoutButton(AuthController authController) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () => authController.logout(),
        icon: const Icon(Icons.logout, size: 20),
        label: const Text('LOGOUT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          foregroundColor: Colors.redAccent,
          elevation: 0,
          side: const BorderSide(color: Colors.redAccent, width: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  void _showRulesDialog(BuildContext context) {
    Get.defaultDialog(
      title: 'Kanglei Marup Rules',
      backgroundColor: AppColors.surface,
      titleStyle: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
      middleTextStyle: const TextStyle(color: Colors.white70),
      middleText: '1. Members must contribute the full amount before the draw.\n2. Winners are selected randomly using a secure server-side logic.\n3. The pool amount is automatically credited to the winner\'s wallet.\n4. Administrative commission is deducted as per group rules.',
      textConfirm: 'I UNDERSTAND',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primary,
      onConfirm: () => Get.back(),
    );
  }
}
