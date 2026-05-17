import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/group_model.dart';
import '../services/firestore_service.dart';

class GroupController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  final isLoading = false.obs;
  final groups = <MarupGroup>[].obs;

  @override
  void onInit() {
    super.onInit();
    _fetchGroups();
  }

  void _fetchGroups() {
    groups.bindStream(
      _firestoreService.collectionStream(
        path: 'groups',
        builder: (data, id) => MarupGroup.fromMap(data, id),
        queryBuilder: (query) => query.orderBy('createdAt', descending: true),
      ),
    );
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
