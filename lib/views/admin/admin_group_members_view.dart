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

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildGroupStats(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('MEMBERS MANAGEMENT', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12)),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: DataTable(
                  columnSpacing: 20,
                  headingRowColor: WidgetStateProperty.all(AppColors.surface),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  columns: const [
                    DataColumn(label: Text('MEMBER', style: TextStyle(color: AppColors.gold, fontSize: 12))),
                    DataColumn(label: Text('MOBILE', style: TextStyle(color: AppColors.gold, fontSize: 12))),
                    DataColumn(label: Text('WALLET', style: TextStyle(color: AppColors.gold, fontSize: 12))),
                    DataColumn(label: Text('STATUS', style: TextStyle(color: AppColors.gold, fontSize: 12))),
                    DataColumn(label: Text('ACTION', style: TextStyle(color: AppColors.gold, fontSize: 12))),
                  ],
                  rows: controller.members.map((member) {
                    final profile = controller.memberProfiles[member.userId];
                    final wallet = controller.memberWallets[member.userId];
                    final isPaid = member.paymentStatus == 'paid';
                    final hasBalance = (wallet?.balance ?? 0) >= (controller.group.value?.contributionAmount ?? 0);

                    return DataRow(
                      color: WidgetStateProperty.resolveWith<Color?>((states) => isPaid ? AppColors.primary.withOpacity(0.02) : null),
                      cells: [
                        DataCell(
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: isPaid ? AppColors.primary.withOpacity(0.1) : Colors.white10,
                                child: Text(profile?.fullName.substring(0, 1).toUpperCase() ?? '?', 
                                  style: TextStyle(color: isPaid ? AppColors.primary : AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 10),
                              Text(profile?.fullName ?? '...', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        DataCell(Text(profile?.mobileNumber ?? 'N/A', style: const TextStyle(color: AppColors.textMuted, fontSize: 12))),
                        DataCell(
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('₹${wallet?.balance.toStringAsFixed(0) ?? '0'}', 
                                style: TextStyle(color: hasBalance ? Colors.green : Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                              if (!hasBalance && !isPaid)
                                const Text('Low Balance', style: TextStyle(color: Colors.redAccent, fontSize: 8)),
                            ],
                          ),
                        ),
                        DataCell(
                          InkWell(
                            onTap: () => controller.togglePaymentStatus(member),
                            borderRadius: BorderRadius.circular(8),
                            child: _buildPaymentChip(isPaid),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              if (!isPaid)
                                IconButton(
                                  icon: Icon(Icons.account_balance_wallet, color: hasBalance ? AppColors.primary : Colors.grey, size: 22),
                                  tooltip: hasBalance ? 'Auto-Collect ₹${controller.group.value?.contributionAmount}' : 'Insufficient Balance',
                                  onPressed: hasBalance ? () => controller.collectFromWallet(member) : null,
                                ),
                              IconButton(
                                icon: Icon(isPaid ? Icons.remove_circle_outline : Icons.check_circle, 
                                  color: isPaid ? Colors.redAccent.withOpacity(0.7) : AppColors.gold, size: 22),
                                tooltip: isPaid ? 'Mark as Unpaid' : 'Manually Mark Paid',
                                onPressed: () => controller.togglePaymentStatus(member),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
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
