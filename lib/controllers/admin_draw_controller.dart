import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/draw_model.dart';
import '../models/group_member_model.dart';
import '../controllers/group_controller.dart';
import '../services/firestore_service.dart';
import '../services/time_service.dart';
import '../routes/app_routes.dart';

class AdminDrawController extends GetxController {
  final FirestoreService _firestore = Get.find<FirestoreService>();
  final TimeService _timeService = Get.find<TimeService>();
  
  final isLoading = false.obs;
  final statusMessage = ''.obs;
  String? _lastAutoTriggeredId;
  Timer? _autoTriggerTimer;

  @override
  void onInit() {
    super.onInit();
    _startAutoTriggerMonitor();
  }

  @override
  void onClose() {
    _autoTriggerTimer?.cancel();
    super.onClose();
  }

  void _startAutoTriggerMonitor() {
    _autoTriggerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkAndAutoTrigger();
    });
  }

  void _checkAndAutoTrigger() {
    if (isLoading.value) return;

    final groupController = Get.find<GroupController>();
    if (groupController.groups.isEmpty) return;

    final upcomingGroups = groupController.groups.where((g) => g.isActive).toList();
    if (upcomingGroups.isEmpty) return;

    upcomingGroups.sort((a, b) => a.drawDate.compareTo(b.drawDate));
    final nextGroup = upcomingGroups.first;

    try {
      final timeParts = nextGroup.drawTime.split(':');
      final drawDateTime = DateTime(
        nextGroup.drawDate.year,
        nextGroup.drawDate.month,
        nextGroup.drawDate.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      final now = _timeService.now;

      if (now.isAfter(drawDateTime) || now.isAtSameMomentAs(drawDateTime)) {
        if (_lastAutoTriggeredId != nextGroup.id) {
          _lastAutoTriggeredId = nextGroup.id;
          startManualSequence(
            nextGroup.id, 
            nextGroup.id, 
            nextGroup.contributionAmount * nextGroup.totalMembers,
          );
        }
      }
    } catch (_) {}
  }

  Future<void> startManualSequence(String drawId, String groupId, double poolAmount) async {
    if (isLoading.value) return;
    isLoading.value = true;
    statusMessage.value = 'Initializing Cinematic Draw...';

    try {
      final members = await _firestore.getCollectionOnce(
        path: 'group_members',
        builder: (data, id) => GroupMember.fromMap(data, id),
        queryBuilder: (q) => q.where('groupId', isEqualTo: groupId)
                              .where('paymentStatus', isEqualTo: 'paid'),
      );

      if (members.isEmpty) {
        Get.snackbar('Error', 'No paid members found.');
        isLoading.value = false;
        return;
      }

      // INITIAL BROADCAST
      await _firestore.setData(
        path: 'draws/$drawId', 
        data: {
          'status': 'starting',
          'groupId': groupId,
          'scheduledAt': DateTime.now().millisecondsSinceEpoch,
          'poolAmount': poolAmount,
          'currentStep': 0,
        },
        merge: true,
      );
      await Future.delayed(const Duration(seconds: 3));

      // STARTING SHAKE
      statusMessage.value = 'BROADCASTING: SHAKING POTS';
      await _updateDraw(drawId, {'status': 'pot_shaking'});
      await Future.delayed(const Duration(seconds: 4));

      // ROUNDS SIMULATION
      int step = 1;
      bool hasWinner = false;
      final rand = Random();
      
      // Shuffle members for fair picking
      final pool = List<GroupMember>.from(members)..shuffle();
      
      for (var member in pool) {
        // COMBINED PHASE: PICKING BOTH AT ONCE
        statusMessage.value = 'STEP $step: PICKING FROM BOTH POTS...';
        
        final userDoc = await _firestore.getDocument(path: 'users/${member.userId}', builder: (data, id) => data);
        final currentName = userDoc?['fullName'] ?? 'Member';
        
        // Decide if this is the winner
        final bool isWinnerRound = rand.nextInt(4) == 0 || member == pool.last;
        final String currentGem = isWinnerRound ? 'assets/ruby.png' : 'assets/gems.png';

        await _updateDraw(drawId, {
          'status': 'picking_both',
          'currentStep': step,
          'currentName': currentName,
          'currentGem': currentGem,
        });

        await Future.delayed(const Duration(seconds: 5));

        if (isWinnerRound) {
          hasWinner = true;
          // FINAL PHASE: WINNER REVEAL
          statusMessage.value = 'WINNER FOUND: $currentName';
          await _updateDraw(drawId, {
            'status': 'winner_reveal',
            'winnerName': currentName,
            'winnerId': member.userId,
          });

          // Payout
          await _processPayout(member.userId, poolAmount, drawId);
          break;
        } else {
          // Small shake between steps
          await _updateDraw(drawId, {'status': 'pot_shaking'});
          await Future.delayed(const Duration(seconds: 2));
        }
        step++;
      }

      await Future.delayed(const Duration(seconds: 8));
      await _updateDraw(drawId, {'status': 'completed'});
      
    } catch (e) {
      Get.snackbar('Draw Error', e.toString());
    } finally {
      isLoading.value = false;
      statusMessage.value = '';
    }
  }

  Future<void> _processPayout(String userId, double amount, String drawId) async {
    final walletPath = 'wallets/$userId';
    final walletDoc = await _firestore.getDocument(path: walletPath, builder: (data, id) => data);
    double currentBalance = (walletDoc?['balance'] ?? 0).toDouble();
    
    await _firestore.updateData(path: walletPath, data: {
      'balance': currentBalance + amount,
      'lastUpdated': _timeService.now.millisecondsSinceEpoch,
    });

    final txId = const Uuid().v4();
    await _firestore.setData(path: 'transactions/$txId', data: {
      'id': txId,
      'userId': userId,
      'amount': amount,
      'type': 'winning',
      'status': 'success',
      'description': 'Marup Won: $amount',
      'timestamp': _timeService.now.millisecondsSinceEpoch,
      'drawId': drawId,
    });
  }

  Future<void> _updateDraw(String id, Map<String, dynamic> data) async {
    await _firestore.updateData(path: 'draws/$id', data: data);
  }
}
