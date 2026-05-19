import 'package:get/get.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

enum KYCStatus { pending, verified, rejected }

class AdminController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  final isLoading = false.obs;
  final users = <UserModel>[].obs;
  final kycPendingUsers = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  void fetchUsers() {
    _firestoreService.collectionStream(
      path: 'users',
      builder: (data, id) => UserModel.fromMap(data, id),
    ).listen((userList) {
      users.assignAll(userList);
      kycPendingUsers.assignAll(userList.where((u) => u.kycStatus == 'pending'));
    });
  }

  Future<void> updateKYCStatus(String userId, String status) async {
    isLoading.value = true;
    try {
      await _firestoreService.updateData(
        path: 'users/$userId',
        data: {'kycStatus': status},
      );
      Get.snackbar('Success', 'KYC status updated to $status');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update KYC: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
