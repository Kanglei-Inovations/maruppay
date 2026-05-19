import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/draw_model.dart';

class LotteryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Rx<DrawModel?> currentDraw = Rx<DrawModel?>(null);
  RxList<String> activeMembers = <String>[].obs;
  
  StreamSubscription<DocumentSnapshot>? _drawSubscription;
  StreamSubscription<QuerySnapshot>? _membersSubscription;

  void initializeDrawSequence(String drawId, String groupId) {
    _listenToDraw(drawId);
    _listenToGroupMembers(groupId);
  }

  void _listenToDraw(String drawId) {
    _drawSubscription?.cancel();
    _drawSubscription = _firestore.collection('draws').doc(drawId).snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        currentDraw.value = DrawModel.fromMap(snapshot.data()!, snapshot.id);
        _handleDrawStatusChange(currentDraw.value!.status);
      }
    });
  }

  void _listenToGroupMembers(String groupId) {
    _membersSubscription?.cancel();
    _membersSubscription = _firestore
        .collection('groups')
        .doc(groupId)
        .collection('group_members')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .listen((snapshot) {
      activeMembers.value = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  void _handleDrawStatusChange(DrawStatus status) {
    // This allows UI to react seamlessly. UI components should Obx() the currentDraw.status
    print("Draw Status Changed: $status");
    switch (status) {
      case DrawStatus.pot_shaking:
        // Play pot shaking sound
        break;
      case DrawStatus.winner_reveal:
        // Play fireworks sound
        break;
      default:
        break;
    }
  }

  @override
  void onClose() {
    _drawSubscription?.cancel();
    _membersSubscription?.cancel();
    super.onClose();
  }
}
