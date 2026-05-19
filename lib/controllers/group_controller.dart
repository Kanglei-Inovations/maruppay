import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/group_model.dart';
import '../models/group_member_model.dart';
import '../models/winner_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';
import './wallet_controller.dart';

class GroupController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  final isLoading = false.obs;
  final groups = <MarupGroup>[].obs;
  final joinedGroupIds = <String>{}.obs;
  final winners = <WinnerModel>[].obs;

  Timer? _drawChecker;

  @override
  void onInit() {
    super.onInit();
    fetchGroups();
    
    // Initial bind if user already exists
    final initialUser = _authService.user.value;
    if (initialUser != null) {
      _listenToJoinedGroups(initialUser.uid);
    }

    ever(_authService.user, (user) {
      if (user != null) {
        _listenToJoinedGroups(user.uid);
      } else {
        joinedGroupIds.clear();
      }
    });
    
    _listenToWinners();
    _startDrawChecker();
  }

  void _startDrawChecker() {
    _drawChecker?.cancel();
    _drawChecker = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkForLiveDraws();
    });
  }

  void _checkForLiveDraws() {
    // Only check if user is on dashboard or relevant page
    if (Get.currentRoute != AppRoutes.memberDashboard) return;

    final now = DateTime.now();
    
    for (var group in groups) {
      if (!joinedGroupIds.contains(group.id)) continue;
      
      try {
        final timeParts = group.drawTime.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        
        final drawDateTime = DateTime(
          group.drawDate.year,
          group.drawDate.month,
          group.drawDate.day,
          hour,
          minute,
        );

        // Auto-navigate if it's within 15 minutes BEFORE or 15 minutes AFTER scheduled time
        // This covers admin starting early and slightly late arrivals.
        final diff = now.difference(drawDateTime);
        if (diff.inMinutes >= -15 && diff.inMinutes < 15) {
          _navigateToDraw(group.id);
          break;
        }
      } catch (_) {}
    }
  }

  void _navigateToDraw(String groupId) {
    Get.snackbar(
      'LIVE DRAW',
      'The draw for your group is starting now!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.amber,
      colorText: Colors.black,
      duration: const Duration(seconds: 5),
    );
    
    Future.delayed(const Duration(seconds: 2), () {
      if (Get.currentRoute == AppRoutes.memberDashboard) {
        Get.toNamed(AppRoutes.lottery, parameters: {
          'drawId': groupId,
          'groupId': groupId,
        });
      }
    });
  }

  @override
  void onClose() {
    _drawChecker?.cancel();
    super.onClose();
  }

  void _listenToJoinedGroups(String userId) {
    // Stream of joined group IDs
    final membershipStream = _firestoreService.collectionStream(
      path: 'group_members',
      builder: (data, id) => GroupMember.fromMap(data, id),
      queryBuilder: (query) => query.where('userId', isEqualTo: userId),
    );

    membershipStream.listen((memberships) {
      joinedGroupIds.assignAll(memberships.map((m) => m.groupId).toSet());
    });
  }

  void _listenToWinners() {
    winners.bindStream(
      _firestoreService.collectionStream(
        path: 'winners',
        builder: (data, id) => WinnerModel.fromMap(data, id),
        queryBuilder: (query) => query.orderBy('drawDate', descending: true).limit(10),
      ),
    );
  }

  Future<void> fetchGroups() async {
    groups.bindStream(
      _firestoreService.collectionStream(
        path: 'groups',
        builder: (data, id) => MarupGroup.fromMap(data, id),
        queryBuilder: (query) => query.orderBy('createdAt', descending: true),
      ),
    );
  }

  // Filtered groups for members
  List<MarupGroup> get activeAndUpcomingGroups => groups
      .where((g) => g.status == GroupStatus.active || g.status == GroupStatus.pending)
      .toList();

  List<MarupGroup> get joinedGroups => groups
      .where((g) => joinedGroupIds.contains(g.id))
      .toList();

  Future<void> joinGroup(MarupGroup group) async {
    final userId = _authService.user.value?.uid;
    if (userId == null) {
      Get.snackbar('Error', 'You must be logged in to join a group');
      return;
    }

    if (joinedGroupIds.contains(group.id)) {
      Get.snackbar('Info', 'You have already joined this group');
      return;
    }

    if (group.totalMembers >= group.memberLimit) {
      Get.snackbar('Error', 'Group is full');
      return;
    }

    // Calculate current draw date time
    DateTime drawDateTime = group.drawDate;
    try {
      final timeParts = group.drawTime.split(':');
      drawDateTime = DateTime(
        group.drawDate.year,
        group.drawDate.month,
        group.drawDate.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
    } catch (_) {}

    final bool isPastDrawTime = DateTime.now().isAfter(drawDateTime);

    if (group.status != GroupStatus.pending && isPastDrawTime) {
      Get.snackbar('Error', 'Cannot join group after the draw has started');
      return;
    }

    isLoading.value = true;
    try {
      final id = const Uuid().v4();
      final member = GroupMember(
        id: id,
        userId: userId,
        groupId: group.id,
        joinedAt: DateTime.now(),
      );

      await _firestoreService.setData(
        path: 'group_members/$id',
        data: member.toMap(),
      );

      // Increment totalMembers in group
      await _firestoreService.updateData(
        path: 'groups/${group.id}',
        data: {'totalMembers': group.totalMembers + 1},
      );

      Get.snackbar('Success', 'Joined group ${group.name}');
    } catch (e) {
      Get.snackbar('Error', 'Failed to join group: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> leaveGroup(MarupGroup group) async {
    final userId = _authService.user.value?.uid;
    if (userId == null) return;

    if (group.status != GroupStatus.pending) {
      Get.snackbar('Error', 'Cannot leave group after it has started');
      return;
    }

    isLoading.value = true;
    try {
      // Find membership document
      final memberships = await _firestoreService.getCollectionOnce(
        path: 'group_members',
        builder: (data, id) => id,
        queryBuilder: (query) => query
            .where('userId', isEqualTo: userId)
            .where('groupId', isEqualTo: group.id),
      );

      if (memberships.isNotEmpty) {
        await _firestoreService.deleteData(path: 'group_members/${memberships.first}');

        // Decrement totalMembers in group
        await _firestoreService.updateData(
          path: 'groups/${group.id}',
          data: {'totalMembers': group.totalMembers - 1},
        );

        Get.snackbar('Success', 'Left group ${group.name}');
      } else {
        Get.snackbar('Error', 'You are not a member of this group');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to leave group: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createGroup({
    required String name,
    required String description,
    required double amount,
    required int limit,
    required DateTime drawDate,
    required String drawTime,
    required GroupType type,
    required double commission,
    required DateTime startDate,
    required DateTime endDate,
    required int totalCycles,
  }) async {
    isLoading.value = true;
    try {
      final id = const Uuid().v4();
      final group = MarupGroup(
        id: id,
        name: name,
        description: description,
        contributionAmount: amount,
        memberLimit: limit,
        drawDate: drawDate,
        drawTime: drawTime,
        groupType: type,
        adminCommission: commission,
        startDate: startDate,
        endDate: endDate,
        createdAt: DateTime.now(),
        totalCycles: totalCycles,
      );

      await _firestoreService.setData(
        path: 'groups/$id',
        data: group.toMap(),
      );
      Get.snackbar('Success', 'Group created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create group: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateGroup(MarupGroup group) async {
    isLoading.value = true;
    try {
      await _firestoreService.updateData(
        path: 'groups/${group.id}',
        data: group.toMap(),
      );
      Get.snackbar('Success', 'Group updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update group: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteGroup(String id) async {
    try {
      await _firestoreService.deleteData(path: 'groups/$id');
      Get.snackbar('Success', 'Group deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete group: $e');
    }
  }

  Future<void> payContribution(MarupGroup group) async {
    final userId = _authService.user.value?.uid;
    if (userId == null) return;

    final walletController = Get.find<WalletController>();
    final balance = walletController.wallet.value?.balance ?? 0;

    if (balance < group.contributionAmount) {
      Get.snackbar('Error', 'Insufficient wallet balance. Please add funds.');
      return;
    }

    isLoading.value = true;
    try {
      // 1. Find membership document
      final memberships = await _firestoreService.getCollectionOnce(
        path: 'group_members',
        builder: (data, id) => id,
        queryBuilder: (query) => query
            .where('userId', isEqualTo: userId)
            .where('groupId', isEqualTo: group.id),
      );

      if (memberships.isNotEmpty) {
        // 2. Update payment status
        await _firestoreService.updateData(
          path: 'group_members/${memberships.first}',
          data: {'paymentStatus': 'paid'},
        );

        // 3. Deduct from wallet
        await walletController.addBalance(-group.contributionAmount);

        Get.snackbar('Success', 'Payment successful for ${group.name}');
      } else {
        Get.snackbar('Error', 'You are not a member of this group');
      }
    } catch (e) {
      Get.snackbar('Error', 'Payment failed: $e');
    } finally {
      isLoading.value = false;
    }
  }
  Stream<List<GroupMember>> getGroupMembersStream(String groupId) {
    return _firestoreService.collectionStream(
      path: 'group_members',
      builder: (data, id) => GroupMember.fromMap(data, id),
      queryBuilder: (q) => q.where('groupId', isEqualTo: groupId),
    );
  }

  // Dashboard Stats
  int get totalGroups => groups.length;
  int get activeGroups => groups.where((g) => g.isActive).length;
  double get totalCollection {
    double total = 0;
    for (var g in groups) {
      total += g.contributionAmount * g.totalMembers;
    }
    return total;
  }
}
