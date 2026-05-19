import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/wallet_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class WalletController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  final isLoading = false.obs;
  final wallet = Rxn<WalletModel>();
  final transactions = <TransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    
    // Initial bind if user already exists
    final initialUser = _authService.user.value;
    if (initialUser != null) {
      _bindWallet(initialUser.uid);
      _bindTransactions(initialUser.uid);
    }

    ever(_authService.user, (user) {
      if (user != null) {
        _bindWallet(user.uid);
        _bindTransactions(user.uid);
      }
    });
  }

  void _bindWallet(String uid) {
    wallet.bindStream(
      _firestoreService
          .collectionStream(
            path: 'wallets',
            builder: (data, id) => WalletModel.fromMap(data),
            queryBuilder: (q) => q.where('userId', isEqualTo: uid),
          )
          .map((wallets) => wallets.isNotEmpty ? wallets.first : null),
    );
  }

  void _bindTransactions(String uid) {
    transactions.bindStream(
      _firestoreService.collectionStream(
        path: 'transactions',
        builder: (data, id) => TransactionModel.fromMap(data, id),
        queryBuilder: (q) => q
            .where('userId', isEqualTo: uid)
            .orderBy('timestamp', descending: true),
      ),
    );
  }

  Future<void> addBalance(double amount) async {
    isLoading.value = true;
    try {
      final uid = _authService.user.value!.uid;
      final currentBalance = wallet.value?.balance ?? 0;

      final transaction = TransactionModel(
        id: const Uuid().v4(),
        userId: uid,
        amount: amount,
        type: TransactionType.deposit,
        description: 'Wallet Deposit',
        timestamp: DateTime.now(),
      );

      await _firestoreService.setData(
        path: 'wallets/$uid',
        data: WalletModel(
          userId: uid,
          balance: currentBalance + amount,
          lastUpdated: DateTime.now(),
        ).toMap(),
      );

      await _firestoreService.setData(
        path: 'transactions/${transaction.id}',
        data: transaction.toMap(),
      );

      Get.snackbar('Success', 'Balance added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add balance: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
