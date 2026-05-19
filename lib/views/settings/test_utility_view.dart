import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/test_utility_controller.dart';
import '../../theme/app_colors.dart';

class TestUtilityView extends GetView<TestUtilityController> {
  const TestUtilityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('DEVELOPER TOOLS'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Colors.black],
          ),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'TESTING UTILITIES',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Generate demo users to fill groups for lottery testing.',
                style: TextStyle(color: Colors.white54),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                if (controller.groups.isEmpty) {
                  return const Center(child: Text('No groups found', style: TextStyle(color: Colors.white24)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.groups.length,
                  itemBuilder: (context, index) {
                    final group = controller.groups[index];
                    final remaining = group.memberLimit - group.totalMembers;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                group.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${group.totalMembers}/${group.memberLimit}',
                                  style: const TextStyle(color: AppColors.primary, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.info_outline, color: Colors.white30, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                '$remaining spots left',
                                style: const TextStyle(color: Colors.white54, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: controller.isLoading.value 
                                      ? null 
                                      : () => controller.addDemoUsers(group.id, 9),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text('ADD 9 DEMO USERS'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: controller.isLoading.value 
                                      ? null 
                                      : () => controller.fundAllMembersWallets(group.id, 20000),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.withValues(alpha: 0.8),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text('FUND WALLETS'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () => controller.clearDemoUsers(group.id),
                                icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                                tooltip: 'Clear Demo Users',
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
            Obx(() => controller.isLoading.value 
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: Colors.amber),
                  ) 
                : const SizedBox()),
          ],
        ),
      ),
    );
  }
}
