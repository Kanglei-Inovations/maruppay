import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../controllers/wallet_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/responsive_sidebar.dart';
import '../../routes/app_routes.dart';
import 'package:intl/intl.dart';

class WalletView extends GetView<WalletController> {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return Scaffold(
      body: Row(
        children: [
          if (!isMobile) const MemberSidebar(activeRoute: AppRoutes.wallet),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: const Text('My Wallet', style: TextStyle(fontWeight: FontWeight.bold)),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              body: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildWalletSummary(context),
                        const SizedBox(height: 24),
                        _buildActionButtons(context),
                        const SizedBox(height: 32),
                        _buildTransactionHistory(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletSummary(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          const Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 12),
          Obx(() => Text(
            '₹${controller.wallet.value?.balance.toStringAsFixed(2) ?? '0.00'}',
            style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold),
          )),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(Icons.add_circle_outline, 'Add Funds', () => _showAddMoneyDialog(context)),
        _buildActionButton(Icons.history, 'History', () {}),
        _buildActionButton(Icons.account_balance, 'Bank', () {}),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text('Recent Transactions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        Obx(() => ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.transactions.length,
          itemBuilder: (context, index) {
            final tx = controller.transactions[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white10,
                child: Icon(
                  tx.amount > 0 ? Icons.arrow_downward : Icons.arrow_upward,
                  color: tx.amount > 0 ? Colors.green : Colors.red,
                ),
              ),
              title: Text(tx.description),
              subtitle: Text(DateFormat('MMM dd, yyyy').format(tx.timestamp)),
              trailing: Text(
                '₹${tx.amount.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: tx.amount > 0 ? Colors.green : Colors.white,
                ),
              ),
            );
          },
        )),
      ],
    );
  }

  void _showAddMoneyDialog(BuildContext context) {
    final amountController = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Add Money'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(prefixText: '₹ ', hintText: 'Enter amount'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null) {
                controller.addBalance(amount);
                Get.back();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
