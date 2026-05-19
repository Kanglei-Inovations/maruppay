
class GroupMember {
  final String id;
  final String userId;
  final String groupId;
  final DateTime joinedAt;
  final String paymentStatus; // 'pending', 'paid'
  final bool hasWon;

  GroupMember({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.joinedAt,
    this.paymentStatus = 'pending',
    this.hasWon = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'groupId': groupId,
      'joinedAt': joinedAt.millisecondsSinceEpoch,
      'paymentStatus': paymentStatus,
      'hasWon': hasWon,
    };
  }

  factory GroupMember.fromMap(Map<String, dynamic> map, String id) {
    return GroupMember(
      id: id,
      userId: map['userId'] ?? '',
      groupId: map['groupId'] ?? '',
      joinedAt: DateTime.fromMillisecondsSinceEpoch(map['joinedAt'] ?? 0),
      paymentStatus: map['paymentStatus'] ?? 'pending',
      hasWon: map['hasWon'] ?? false,
    );
  }
}
