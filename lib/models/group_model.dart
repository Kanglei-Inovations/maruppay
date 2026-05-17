import 'package:flutter/material.dart';

enum GroupType { monthly, weekly, daily }

enum GroupStatus { pending, active, paused, completed }

class MarupGroup {
  final String id;
  final String name;
  final String description;
  final double contributionAmount;
  final int memberLimit;
  final int totalMembers;
  final DateTime drawDate;
  final String drawTime; // HH:mm format
  final GroupType groupType;
  final double adminCommission;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;
  final int currentCycle;
  final int totalCycles;

  MarupGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.contributionAmount,
    required this.memberLimit,
    this.totalMembers = 0,
    required this.drawDate,
    required this.drawTime,
    required this.groupType,
    required this.adminCommission,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    required this.createdAt,
    this.currentCycle = 1,
    required this.totalCycles,
  });

  GroupStatus get status {
    if (!isActive) return GroupStatus.paused;
    if (totalMembers < memberLimit) return GroupStatus.pending;
    if (currentCycle > totalCycles) return GroupStatus.completed;
    return GroupStatus.active;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'contributionAmount': contributionAmount,
      'memberLimit': memberLimit,
      'totalMembers': totalMembers,
      'drawDate': drawDate.millisecondsSinceEpoch,
      'drawTime': drawTime,
      'groupType': groupType.name,
      'adminCommission': adminCommission,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'currentCycle': currentCycle,
      'totalCycles': totalCycles,
    };
  }

  factory MarupGroup.fromMap(Map<String, dynamic> map, String id) {
    return MarupGroup(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      contributionAmount: (map['contributionAmount'] ?? 0).toDouble(),
      memberLimit: map['memberLimit'] ?? 0,
      totalMembers: map['totalMembers'] ?? 0,
      drawDate: DateTime.fromMillisecondsSinceEpoch(map['drawDate'] ?? 0),
      drawTime: map['drawTime'] ?? '10:00',
      groupType: GroupType.values.firstWhere(
        (e) => e.name == map['groupType'],
        orElse: () => GroupType.monthly,
      ),
      adminCommission: (map['adminCommission'] ?? 0).toDouble(),
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate'] ?? 0),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate'] ?? 0),
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      currentCycle: map['currentCycle'] ?? 1,
      totalCycles: map['totalCycles'] ?? 12,
    );
  }

  MarupGroup copyWith({
    String? name,
    String? description,
    double? contributionAmount,
    int? memberLimit,
    DateTime? drawDate,
    String? drawTime,
    GroupType? groupType,
    double? adminCommission,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    int? currentCycle,
    int? totalCycles,
  }) {
    return MarupGroup(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      contributionAmount: contributionAmount ?? this.contributionAmount,
      memberLimit: memberLimit ?? this.memberLimit,
      totalMembers: totalMembers,
      drawDate: drawDate ?? this.drawDate,
      drawTime: drawTime ?? this.drawTime,
      groupType: groupType ?? this.groupType,
      adminCommission: adminCommission ?? this.adminCommission,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      currentCycle: currentCycle ?? this.currentCycle,
      totalCycles: totalCycles ?? this.totalCycles,
    );
  }
}
