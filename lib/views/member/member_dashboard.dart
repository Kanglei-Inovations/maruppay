import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../controllers/wallet_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/group_controller.dart';
import '../../theme/app_colors.dart';
import '../../models/group_model.dart';
import '../../models/group_member_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../services/time_service.dart';
import '../../routes/app_routes.dart';
import '../../widgets/countdown_timer.dart';
import '../../widgets/live_clock.dart';

class MemberDashboard extends GetView<WalletController> {
  const MemberDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();
    final groupController = Get.find<GroupController>();
    final timeService = Get.find<TimeService>();
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, profileController),
          
          SliverPadding(
            padding: EdgeInsets.all(isMobile ? 20 : 32),
            sliver: SliverToBoxAdapter(
              child: _buildWalletCard(context, controller),
            ),
          ),

          // UPCOMING DRAW COUNTDOWN
          Obx(() => _buildGlobalCountdown(groupController, timeService)),
          
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: _buildSectionHeader('MY ACTIVE MARUPS', () {}),
            ),
          ),
          Obx(() => _buildJoinedGroups(groupController)),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
            sliver: SliverToBoxAdapter(
              child: _buildSectionHeader('EXPLORE NEW MARUPS', () {}),
            ),
          ),
          Obx(() => _buildExploreList(groupController)),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: isMobile ? _buildBottomNav(context) : null,
    );
  }

  Widget _buildAppBar(BuildContext context, ProfileController profileController) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      actions: [
        const Center(child: LiveClock()),
        const SizedBox(width: 20),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Obx(() => Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Welcome back,', style: TextStyle(color: AppColors.textMuted, fontSize: 10, letterSpacing: 1)),
                Text(
                  profileController.currentUser.value?.fullName ?? 'Member',
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Spacer(),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.surface,
              child: const Icon(Icons.person_outline, color: AppColors.gold, size: 18),
            ),
          ],
        )),
      ),
    );
  }

  Widget _buildGlobalCountdown(GroupController controller, TimeService timeService) {
    final joined = controller.joinedGroups;
    if (joined.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final now = timeService.now;

    final List<Map<String, dynamic>> timedGroups = [];
    for (var g in joined) {
      try {
        final parts = g.drawTime.split(':');
        final drawDT = DateTime(g.drawDate.year, g.drawDate.month, g.drawDate.day, int.parse(parts[0]), int.parse(parts[1]));
        
        if (drawDT.isAfter(now.subtract(const Duration(minutes: 30)))) {
          timedGroups.add({'group': g, 'time': drawDT});
        }
      } catch (_) {}
    }

    if (timedGroups.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    timedGroups.sort((a, b) => (a['time'] as DateTime).compareTo(b['time'] as DateTime));
    final nextGroup = timedGroups.first['group'] as MarupGroup;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      sliver: SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.gold.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.gold.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              const Text('NEXT MARUP DRAW IN', style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 12),
              CountdownTimer(targetDate: nextGroup.drawDate, targetTime: nextGroup.drawTime),
              const SizedBox(height: 8),
              Text(nextGroup.name, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context, WalletController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 18),
              SizedBox(width: 8),
              Text('Available Balance', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() => Text(
            '₹${controller.wallet.value?.balance.toStringAsFixed(2) ?? '0.00'}',
            style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          )),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildCompactAction(Icons.add_circle_outline, 'Add Funds', () => Get.toNamed(AppRoutes.wallet)),
              const SizedBox(width: 12),
              _buildCompactAction(Icons.history, 'History', () => Get.toNamed(AppRoutes.settings)),
            ],
          ),
        ],
      ),
    ).animate().scale(duration: const Duration(milliseconds: 600), curve: Curves.easeOut);
  }

  Widget _buildCompactAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.gold, letterSpacing: 1.5)),
        const Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.textMuted),
      ],
    );
  }

  Widget _buildJoinedGroups(GroupController controller) {
    final joined = controller.joinedGroups;
    if (joined.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
          child: const Column(
            children: [
              Icon(Icons.layers_clear_outlined, color: AppColors.textMuted, size: 32),
              SizedBox(height: 8),
              Text('You haven\'t joined any Marups yet.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildMemberGroupCard(context, controller, joined[index], true),
        childCount: joined.length,
      ),
    );
  }

  Widget _buildExploreList(GroupController controller) {
    final explore = controller.groups.where((g) => !controller.joinedGroupIds.contains(g.id)).toList();
    if (explore.isEmpty) {
      return SliverToBoxAdapter(
        child: const Center(child: Text('No new Marups available.', style: TextStyle(color: AppColors.textMuted))),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildMemberGroupCard(context, controller, explore[index], false),
        childCount: explore.length,
      ),
    );
  }

  Widget _buildMemberGroupCard(BuildContext context, GroupController controller, MarupGroup group, bool isJoined) {
    final isFull = group.totalMembers >= group.memberLimit;
    
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isJoined ? AppColors.primary.withOpacity(0.2) : Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('₹${group.contributionAmount}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(width: 8),
                        Text('• ${group.totalMembers}/${group.memberLimit} Members', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(DateFormat('dd MMM').format(group.drawDate), style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(group.drawTime, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildCompactInfoAction(Icons.people_outline, 'Members', () => _showMembersList(context, group.id)),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (group.status == GroupStatus.active && isJoined) {
                      Get.toNamed(AppRoutes.lottery, parameters: {'drawId': group.id, 'groupId': group.id});
                    } else if (!isJoined) {
                      if (!isFull) {
                        controller.joinGroup(group);
                      } else {
                        Get.snackbar('Group Full', 'This marup group has reached its member limit.', snackPosition: SnackPosition.BOTTOM);
                      }
                    } else {
                      Get.snackbar('Joined', 'You are already a member. Waiting for draw.', snackPosition: SnackPosition.BOTTOM);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (group.status == GroupStatus.active && isJoined) ? AppColors.primary : (isJoined ? Colors.white10 : (isFull ? Colors.grey.shade800 : AppColors.primary)),
                    foregroundColor: (isJoined && group.status != GroupStatus.active) ? Colors.white70 : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(group.status == GroupStatus.active && isJoined ? 'WATCH LIVE DRAW' : (isJoined ? 'JOINED' : (isFull ? 'FULL' : 'JOIN NOW'))),
                ),
              ),
              if (isJoined && group.status == GroupStatus.pending) ...[
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                  tooltip: 'Unjoin Group',
                  onPressed: () => controller.leaveGroup(group),
                ),
              ],
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05);
  }

  Widget _buildCompactInfoAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
        child: Row(
          children: [
            Icon(icon, color: AppColors.gold, size: 14),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  void _showMembersList(BuildContext context, String groupId) {
    final firestore = Get.find<FirestoreService>();
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Group Members', style: TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<GroupMember>>(
                stream: Get.find<GroupController>().getGroupMembersStream(groupId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final members = snapshot.data!;
                  if (members.isEmpty) return const Center(child: Text('No members yet.', style: TextStyle(color: AppColors.textMuted)));
                  
                  return ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final m = members[index];
                      return FutureBuilder<UserModel>(
                        future: Get.find<FirestoreService>().getDocument(
                          path: 'users/${m.userId}', 
                          builder: (data, id) => UserModel.fromMap(data, id)
                        ),
                        builder: (context, userSnap) {
                          final user = userSnap.data;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: Colors.white10, 
                              child: Text(user?.fullName.isNotEmpty == true ? user!.fullName[0] : '?', 
                                style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold))
                            ),
                            title: Text(user?.fullName ?? 'Loading...', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text(m.paymentStatus.toUpperCase(), style: TextStyle(color: m.paymentStatus == 'paid' ? AppColors.primary : AppColors.gold, fontSize: 9, fontWeight: FontWeight.w900)),
                            trailing: m.paymentStatus == 'paid' ? const Icon(Icons.verified, color: AppColors.primary, size: 16) : null,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(Icons.home_filled, 'Home', true, () {}),
            _buildNavItem(Icons.account_balance_wallet, 'Wallet', false, () => Get.toNamed(AppRoutes.wallet)),
            _buildNavItem(Icons.history, 'Activity', false, () => Get.toNamed(AppRoutes.settings)),
            _buildNavItem(Icons.settings, 'Settings', false, () => Get.toNamed(AppRoutes.settings)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? AppColors.primary : AppColors.textMuted, size: 22),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isActive ? AppColors.primary : AppColors.textMuted, fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
