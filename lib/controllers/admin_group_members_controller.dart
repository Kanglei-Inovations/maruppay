import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/group_member_model.dart';
import '../models/user_model.dart';
import '../models/group_model.dart';
import '../models/wallet_model.dart';
import '../services/firestore_service.dart';

class AdminGroupMembersController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final String groupId = Get.arguments as String;

  final isLoading = true.obs;
  final members = <GroupMember>[].obs;
  final memberProfiles = <String, UserModel>{}.obs;
  final memberWallets = <String, WalletModel>{}.obs;
  final group = Rxn<MarupGroup>();

  @override
  void onInit() {
    super.onInit();
    _fetchGroupDetails();
    _listenToMembers();
  }

  Future<void> _fetchGroupDetails() async {
    final groupData = await _firestoreService.getDocument(
      path: 'groups/$groupId',
      builder: (data, id) => MarupGroup.fromMap(data, id),
    );
    group.value = groupData;
  }

  void _listenToMembers() {
    _firestoreService.collectionStream(
      path: 'group_members',
      builder: (data, id) => GroupMember.fromMap(data, id),
      queryBuilder: (query) => query.where('groupId', isEqualTo: groupId),
    ).listen((memberList) async {
      members.assignAll(memberList);
      
      // Fetch user profiles and wallets for each member
      for (var member in memberList) {
        if (!memberProfiles.containsKey(member.userId)) {
          final profile = await _firestoreService.getDocument(
            path: 'users/${member.userId}',
            builder: (data, id) => UserModel.fromMap(data, id),
          );
          memberProfiles[member.userId] = profile;
        }

        // Fetch Wallet
        final walletData = await _firestoreService.getDocument(
          path: 'wallets/${member.userId}',
          builder: (data, id) => WalletModel.fromMap(data),
        );
        if (walletData != null) {
          memberWallets[member.userId] = walletData;
        } else {
          // Initialize empty wallet model if not found
          memberWallets[member.userId] = WalletModel(userId: member.userId, lastUpdated: DateTime.now());
        }
      }
      isLoading.value = false;
    });
  }

  Future<void> togglePaymentStatus(GroupMember member) async {
    final newStatus = member.paymentStatus == 'paid' ? 'pending' : 'paid';
    await _firestoreService.updateData(
      path: 'group_members/${member.id}',
      data: {'paymentStatus': newStatus},
    );
  }

  Future<void> collectFromWallet(GroupMember member) async {
    final wallet = memberWallets[member.userId];
    final amount = group.value?.contributionAmount ?? 0;

    if (wallet == null || wallet.balance < amount) {
      Get.snackbar('Insufficient Balance', 'User does not have enough balance in wallet.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      // 1. Deduct from wallet
      await _firestoreService.updateData(
        path: 'wallets/${member.userId}',
        data: {
          'balance': wallet.balance - amount,
          'lastUpdated': DateTime.now().millisecondsSinceEpoch,
        },
      );

      // 2. Create transaction record
      final txId = const Uuid().v4();
      final transaction = TransactionModel(
        id: txId,
        userId: member.userId,
        groupId: groupId,
        amount: amount,
        type: TransactionType.deduction,
        description: 'Auto-collection for ${group.value?.name}',
        timestamp: DateTime.now(),
      );
      await _firestoreService.setData(path: 'transactions/$txId', data: transaction.toMap());

      // 3. Update member payment status
      await _firestoreService.updateData(
        path: 'group_members/${member.id}',
        data: {'paymentStatus': 'paid'},
      );

      Get.snackbar('Success', 'Amount collected from wallet successfully.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to collect: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
