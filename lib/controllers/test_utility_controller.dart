import 'package:get/get.dart';
import '../models/group_member_model.dart';
import '../models/user_model.dart';
import '../models/group_model.dart';
import '../services/firestore_service.dart';
import 'package:uuid/uuid.dart';

class TestUtilityController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final isLoading = false.obs;
  final groups = <MarupGroup>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadGroups();
  }

  Future<void> loadGroups() async {
    groups.bindStream(
      _firestoreService.collectionStream(
        path: 'groups',
        builder: (data, id) => MarupGroup.fromMap(data, id),
      ),
    );
  }

  Future<void> addDemoUsers(String groupId, int count) async {
    try {
      isLoading.value = true;
      final uuid = const Uuid();

      for (int i = 0; i < count; i++) {
        final demoUid = 'demo_${uuid.v4().substring(0, 8)}';
        
        // 1. Create Demo User Document
        final demoUser = UserModel(
          uid: demoUid,
          email: '$demoUid@marup.test',
          fullName: 'Demo Test User ${i + 1}',
          mobileNumber: '910000000${i + 1}',
          address: 'Demo Test Lab',
          district: 'Testing District',
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
          isProfileComplete: true,
          joinedGroups: [groupId],
          role: UserRole.member,
        );

        await _firestoreService.setData(
          path: 'users/$demoUid',
          data: demoUser.toMap(),
        );

        // 2. Create Group Member Document
        final member = GroupMember(
          id: 'mem_${uuid.v4().substring(0, 8)}',
          userId: demoUid,
          groupId: groupId,
          joinedAt: DateTime.now(),
          paymentStatus: 'paid',
        );

        await _firestoreService.setData(
          path: 'group_members/${member.id}',
          data: member.toMap(),
        );
      }

      // 3. Update Group's member count
      final currentGroup = groups.firstWhere((g) => g.id == groupId);
      await _firestoreService.updateData(
        path: 'groups/$groupId',
        data: {'totalMembers': currentGroup.totalMembers + count},
      );

      Get.snackbar('Success', 'Generated and joined $count demo users');
    } catch (e) {
      Get.snackbar('Error', 'Failed: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fundAllMembersWallets(String groupId, double amount) async {
    try {
      isLoading.value = true;
      final uuid = const Uuid();

      // 1. Get all members for this group
      final members = await _firestoreService.getCollectionOnce(
        path: 'group_members',
        builder: (data, id) => GroupMember.fromMap(data, id),
        queryBuilder: (query) => query.where('groupId', isEqualTo: groupId),
      );

      if (members.isEmpty) {
        Get.snackbar('Info', 'No members found in this group');
        return;
      }

      for (var member in members) {
        // 2. Get current wallet balance
        final walletData = await _firestoreService.getDocument(
          path: 'wallets/${member.userId}',
          builder: (data, id) => data,
        ).catchError((_) => <String, dynamic>{});

        final currentBalance = (walletData['balance'] ?? 0.0).toDouble();

        // 3. Update Wallet
        await _firestoreService.setData(
          path: 'wallets/${member.userId}',
          data: {
            'userId': member.userId,
            'balance': currentBalance + amount,
            'lastUpdated': DateTime.now().millisecondsSinceEpoch,
          },
        );

        // 4. Create Transaction record
        final txId = uuid.v4();
        await _firestoreService.setData(
          path: 'transactions/$txId',
          data: {
            'id': txId,
            'userId': member.userId,
            'amount': amount,
            'type': 'deposit',
            'description': 'Test Utility Funding',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          },
        );
      }

      Get.snackbar('Success', 'Added ₹$amount to ${members.length} members');
    } catch (e) {
      Get.snackbar('Error', 'Funding failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> clearDemoUsers(String groupId) async {
    try {
      isLoading.value = true;
      
      // Get all members for this group
      final members = await _firestoreService.getCollectionOnce(
        path: 'group_members',
        builder: (data, id) => GroupMember.fromMap(data, id),
        queryBuilder: (query) => query.where('groupId', isEqualTo: groupId),
      );

      for (var member in members) {
        if (member.userId.startsWith('demo_')) {
          // Delete member doc
          await _firestoreService.deleteData(path: 'group_members/${member.id}');
          // Delete user doc
          await _firestoreService.deleteData(path: 'users/${member.userId}');
        }
      }

      // Reset count (this is simplified, better would be to count non-demo members)
      // For testing, let's just count remaining members
      final remainingMembers = await _firestoreService.getCollectionOnce(
        path: 'group_members',
        builder: (data, id) => id,
        queryBuilder: (query) => query.where('groupId', isEqualTo: groupId),
      );

      await _firestoreService.updateData(
        path: 'groups/$groupId',
        data: {'totalMembers': remainingMembers.length},
      );

      Get.snackbar('Success', 'Cleared demo users from group');
    } catch (e) {
      Get.snackbar('Error', 'Failed to clear: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetAllData() async {
    try {
      isLoading.value = true;
      
      // 1. Delete all Group Members
      final members = await _firestoreService.getCollectionOnce(
        path: 'group_members',
        builder: (data, id) => id,
      );
      for (var id in members) {
        await _firestoreService.deleteData(path: 'group_members/$id');
      }

      // 2. Delete all Winners
      final winners = await _firestoreService.getCollectionOnce(
        path: 'winners',
        builder: (data, id) => id,
      );
      for (var id in winners) {
        await _firestoreService.deleteData(path: 'winners/$id');
      }

      // 3. Delete all Transactions
      final txs = await _firestoreService.getCollectionOnce(
        path: 'transactions',
        builder: (data, id) => id,
      );
      for (var id in txs) {
        await _firestoreService.deleteData(path: 'transactions/$id');
      }

      // 4. Delete Users and Wallets EXCEPT Admins
      final users = await _firestoreService.getCollectionOnce(
        path: 'users',
        builder: (data, id) => UserModel.fromMap(data, id),
      );

      for (var user in users) {
        // Skip specific admin email
        if (user.email == 'alaftabshah@gmail.com' || user.role == UserRole.superAdmin) {
          continue;
        }

        // Delete user's wallet
        await _firestoreService.deleteData(path: 'wallets/${user.uid}');
        // Delete user doc
        await _firestoreService.deleteData(path: 'users/${user.uid}');
      }

      // 5. Reset Group counts
      for (var group in groups) {
        await _firestoreService.updateData(
          path: 'groups/${group.id}',
          data: {'totalMembers': 0},
        );
      }

      Get.snackbar('Success', 'System data reset successfully (Admins preserved)');
    } catch (e) {
      Get.snackbar('Error', 'Reset failed: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
