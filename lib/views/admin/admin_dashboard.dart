import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/group_controller.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/admin_draw_controller.dart';
import '../../models/group_model.dart';
import '../../services/time_service.dart';
import '../../theme/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../widgets/admin/create_group_dialog.dart';
import '../../widgets/countdown_timer.dart';
import '../../widgets/live_clock.dart';

class AdminDashboard extends GetView<GroupController> {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final adminController = Get.find<AdminController>();
    final drawController = Get.find<AdminDrawController>();
    final timeService = Get.find<TimeService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Admin Console', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
        actions: [
          const Center(child: LiveClock()),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.testUtility),
            icon: const Icon(Icons.bug_report_outlined, color: AppColors.gold),
            tooltip: 'Test Utilities',
          ),
          IconButton(
            onPressed: () => authController.logout(),
            icon: const Icon(Icons.logout, color: AppColors.error),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => Get.dialog(const CreateGroupDialog()),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Marup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ADMIN GLOBAL COUNTDOWN
            Obx(() => _buildAdminCountdown(drawController, timeService)),
            const SizedBox(height: 12),
            
            _buildStatGrid(),
            const SizedBox(height: 32),
            
            _buildSectionTitle('KYC Verification Pending'),
            const SizedBox(height: 16),
            Obx(() => _buildKYCList(adminController)),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Manage Groups'),
            const SizedBox(height: 16),
            Obx(() => _buildGroupList()),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCountdown(AdminDrawController drawController, TimeService timeService) {
    if (controller.groups.isEmpty) return const SizedBox.shrink();

    final now = timeService.now;

    // 1. Get all groups and sort by draw date/time
    final sortedGroups = List<MarupGroup>.from(controller.groups);
    sortedGroups.sort((a, b) {
      try {
        final aParts = a.drawTime.split(':');
        final bParts = b.drawTime.split(':');
        final aDT = DateTime(a.drawDate.year, a.drawDate.month, a.drawDate.day, int.parse(aParts[0]), int.parse(aParts[1]));
        final bDT = DateTime(b.drawDate.year, b.drawDate.month, b.drawDate.day, int.parse(bParts[0]), int.parse(bParts[1]));
        return aDT.compareTo(bDT);
      } catch (_) {
        return a.drawDate.compareTo(b.drawDate);
      }
    });

    // 2. Find the most relevant group (either the one happening now/soon, or the next one)
    MarupGroup? nextGroup;
    DateTime? nextTime;

    for (var g in sortedGroups) {
      try {
        final parts = g.drawTime.split(':');
        final drawDT = DateTime(g.drawDate.year, g.drawDate.month, g.drawDate.day, int.parse(parts[0]), int.parse(parts[1]));
        
        // If it's in the future or was recently (last 2 hours), pick it
        if (drawDT.isAfter(now.subtract(const Duration(hours: 2)))) {
          nextGroup = g;
          nextTime = drawDT;
          break;
        }
      } catch (_) {}
    }

    // Fallback to the first group if none matched the "recent" criteria
    nextGroup ??= sortedGroups.first;
    if (nextTime == null) {
      try {
        final parts = nextGroup.drawTime.split(':');
        nextTime = DateTime(nextGroup.drawDate.year, nextGroup.drawDate.month, nextGroup.drawDate.day, int.parse(parts[0]), int.parse(parts[1]));
      } catch (_) {
        nextTime = nextGroup.drawDate;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gold.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Text('NEXT GLOBAL DRAW', style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 12),
          
          CountdownTimer(
            targetDate: nextGroup.drawDate, 
            targetTime: nextGroup.drawTime,
            fontSize: 24,
          ),
          
          const SizedBox(height: 16),
          
          Obx(() => drawController.isLoading.value 
            ? Column(
                children: [
                  const CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2),
                  const SizedBox(height: 12),
                  Text(drawController.statusMessage.value.toUpperCase(), 
                    style: const TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ],
              )
            : _buildDrawActionButton(nextGroup!, drawController, nextTime!, now)
          ),
          
          const SizedBox(height: 12),
          Text(nextGroup.name, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDrawActionButton(MarupGroup nextGroup, AdminDrawController drawController, DateTime drawTime, DateTime now) {
    // Admins can always start the draw if it's within 15 minutes of scheduled time OR if it's already overdue
    final bool isReady = now.isAfter(drawTime.subtract(const Duration(minutes: 15)));

    return SizedBox(
      height: 45,
      width: 200,
      child: ElevatedButton(
        onPressed: () {
          drawController.startManualSequence(
            nextGroup.id, 
            nextGroup.id, 
            nextGroup.contributionAmount * nextGroup.totalMembers,
          );
          Get.toNamed(
            AppRoutes.lottery,
            parameters: {
              'drawId': nextGroup.id,
              'groupId': nextGroup.id,
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isReady ? AppColors.gold.withOpacity(0.2) : Colors.white10,
          foregroundColor: isReady ? AppColors.gold : Colors.white38,
          side: BorderSide(color: isReady ? AppColors.gold : Colors.white10, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(now.isAfter(drawTime) ? 'START OVERDUE DRAW' : 'START DRAW NOW', 
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppColors.gold,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        fontSize: 12,
      ),
    );
  }

  Widget _buildStatGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Total Groups', controller.totalGroups.toString(), Icons.layers, AppColors.primary),
        _buildStatCard('Total Revenue', '₹${controller.totalCollection.toStringAsFixed(0)}', Icons.payments, AppColors.gold),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildKYCList(AdminController adminController) {
    if (adminController.kycPendingUsers.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
        child: const Center(child: Text('All KYC up to date!', style: TextStyle(color: AppColors.textMuted))),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: adminController.kycPendingUsers.length,
      itemBuilder: (context, index) {
        final user = adminController.kycPendingUsers[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: Colors.white10, child: Text(user.fullName[0])),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(user.mobileNumber, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.check_circle, color: AppColors.primary),
                onPressed: () => adminController.updateKYCStatus(user.uid, 'verified'),
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: AppColors.error),
                onPressed: () => adminController.updateKYCStatus(user.uid, 'rejected'),
              ),
            ],
          ),
        );
      },
    ).animate().fadeIn();
  }

  Widget _buildGroupList() {
    if (controller.groups.isEmpty) return const SizedBox.shrink();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.groups.length,
      itemBuilder: (context, index) {
        final group = controller.groups[index];
        return InkWell(
          onTap: () => Get.toNamed(AppRoutes.adminMembers, arguments: group.id),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.group, color: AppColors.gold),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('${group.totalMembers}/${group.memberLimit} Members • ₹${group.contributionAmount}', 
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.gold, size: 20),
                  onPressed: () => Get.dialog(CreateGroupDialog(group: group)),
                ),
                const Icon(Icons.chevron_right, color: Colors.white24),
              ],
            ),
          ),
        );
      },
    );
  }
}
