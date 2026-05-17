class WinnerModel {
  final String id;
  final String groupId;
  final String userId;
  final String userName;
  final double winningAmount;
  final int cycleNumber;
  final DateTime drawDate;
  final String luckyNumber;

  WinnerModel({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.userName,
    required this.winningAmount,
    required this.cycleNumber,
    required this.drawDate,
    required this.luckyNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'userId': userId,
      'userName': userName,
      'winningAmount': winningAmount,
      'cycleNumber': cycleNumber,
      'drawDate': drawDate.millisecondsSinceEpoch,
      'luckyNumber': luckyNumber,
    };
  }

  factory WinnerModel.fromMap(Map<String, dynamic> map, String id) {
    return WinnerModel(
      id: id,
      groupId: map['groupId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      winningAmount: (map['winningAmount'] ?? 0).toDouble(),
      cycleNumber: map['cycleNumber'] ?? 1,
      drawDate: DateTime.fromMillisecondsSinceEpoch(map['drawDate'] ?? 0),
      luckyNumber: map['luckyNumber'] ?? '',
    );
  }
}
