import 'package:cloud_firestore/cloud_firestore.dart';

enum DrawStatus {
  scheduled,
  starting,
  pot_shaking,
  selecting_name,
  selecting_gem,
  picking_both,
  winner_reveal,
  completed
}

class DrawModel {
  final String drawId;
  final String groupId;
  final DateTime scheduledAt;
  final DrawStatus status;
  final String? currentName;
  final String? currentGem;
  final String? winnerId;
  final String? winnerName;
  final double poolAmount;
  final int currentStep;

  DrawModel({
    required this.drawId,
    required this.groupId,
    required this.scheduledAt,
    required this.status,
    this.currentName,
    this.currentGem,
    this.winnerId,
    this.winnerName,
    required this.poolAmount,
    this.currentStep = 0,
  });

  factory DrawModel.fromMap(Map<String, dynamic> data, String id) {
    DateTime scheduledAt;
    var rawScheduled = data['scheduledAt'];
    if (rawScheduled is Timestamp) {
      scheduledAt = rawScheduled.toDate();
    } else if (rawScheduled is int) {
      scheduledAt = DateTime.fromMillisecondsSinceEpoch(rawScheduled);
    } else {
      scheduledAt = DateTime.now();
    }

    return DrawModel(
      drawId: id,
      groupId: data['groupId'] ?? '',
      scheduledAt: scheduledAt,
      status: DrawStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => DrawStatus.scheduled,
      ),
      currentName: data['currentName'],
      currentGem: data['currentGem'],
      winnerId: data['winnerId'],
      winnerName: data['winnerName'],
      poolAmount: (data['poolAmount'] ?? 0.0).toDouble(),
      currentStep: data['currentStep'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'status': status.toString().split('.').last,
      'currentName': currentName,
      'currentGem': currentGem,
      'winnerId': winnerId,
      'winnerName': winnerName,
      'poolAmount': poolAmount,
      'currentStep': currentStep,
    };
  }
}
