import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/admin_group_members_controller.dart';
import '../../theme/app_colors.dart';

import '../../widgets/admin/create_group_dialog.dart';

class AdminGroupMembersView extends GetView<AdminGroupMembersController> {
  const AdminGroupMembersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Obx(() => Text(controller.group.value?.name ?? 'Loading Members...', 
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Obx(() => controller.group.value != null 
            ? IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.gold),
                onPressed: () => Get.dialog(CreateGroupDialog(group: controller.group.value)),
              )
            : const SizedBox.shrink()),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.members.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (controller.members.isEmpty) {
          return const Center(child: Text('No members have joined yet.', style: TextStyle(color: AppColors.textMuted)));
        }

        return Column(
          children: [
            _buildGroupStats(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Text('MEMBERS LIST', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12)),
                  Spacer(),
                  Text('PAYMENT STATUS', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: controller.members.length,
                itemBuilder: (context, index) {
                  final member = controller.members[index];
                  final profile = controller.memberProfiles[member.userId];
                  final wallet = controller.memberWallets[member.userId];
                  final isPaid = member.paymentStatus == 'paid';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isPaid ? AppColors.primary.withOpacity(0.2) : Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white10,
                              child: Text(profile?.fullName.substring(0, 1).toUpperCase() ?? '?', 
                                style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(profile?.fullName ?? 'Loading...', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  Text(profile?.mobileNumber ?? 'N/A', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                ],
                              ),
                            ),
                            _buildPaymentChip(isPaid),
                          ],
                        ),
                        Divider(height: 24, color: Colors.white.withOpacity(0.05)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Wallet Balance', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                                Text('₹${wallet?.balance.toStringAsFixed(2) ?? '0.00'}', 
                                  style: TextStyle(color: (wallet?.balance ?? 0) >= (controller.group.value?.contributionAmount ?? 0) ? Colors.green : Colors.redAccent, 
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                            if (!isPaid)
                              ElevatedButton(
                                onPressed: () => controller.collectFromWallet(member),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.gold.withOpacity(0.1),
                                  foregroundColor: AppColors.gold,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: AppColors.gold, width: 0.5)),
                                ),
                                child: const Text('Collect Amount', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: Duration(milliseconds: index * 100)).slideX(begin: 0.05);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildGroupStats() {
    final paidCount = controller.members.where((m) => m.paymentStatus == 'paid').length;
    final totalAmount = paidCount * (controller.group.value?.contributionAmount ?? 0);

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('PAID', paidCount.toString(), Colors.white),
          Container(width: 1, height: 40, color: Colors.white24),
          _statItem('PENDING', (controller.members.length - paidCount).toString(), Colors.white70),
          Container(width: 1, height: 40, color: Colors.white24),
          _statItem('TOTAL POOL', '₹$totalAmount', Colors.white),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildPaymentChip(bool isPaid) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPaid ? AppColors.primary.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isPaid ? AppColors.primary : AppColors.error, width: 0.5),
      ),
      child: Text(isPaid ? 'PAID' : 'PENDING', 
        style: TextStyle(color: isPaid ? AppColors.primary : AppColors.error, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
