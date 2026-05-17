enum TransactionType { deposit, deduction, winning, commission }

enum TransactionStatus { pending, success, failed }

class TransactionModel {
  final String id;
  final String userId;
  final String? groupId;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final String description;
  final DateTime timestamp;

  TransactionModel({
    required this.id,
    required this.userId,
    this.groupId,
    required this.amount,
    required this.type,
    this.status = TransactionStatus.success,
    required this.description,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'groupId': groupId,
      'amount': amount,
      'type': type.name,
      'status': status.name,
      'description': description,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return TransactionModel(
      id: id,
      userId: map['userId'] ?? '',
      groupId: map['groupId'],
      amount: (map['amount'] ?? 0).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.deposit,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TransactionStatus.success,
      ),
      description: map['description'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
    );
  }
}

class WalletModel {
  final String userId;
  final double balance;
  final double reservedAmount;
  final DateTime lastUpdated;

  WalletModel({
    required this.userId,
    this.balance = 0,
    this.reservedAmount = 0,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'balance': balance,
      'reservedAmount': reservedAmount,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      userId: map['userId'] ?? '',
      balance: (map['balance'] ?? 0).toDouble(),
      reservedAmount: (map['reservedAmount'] ?? 0).toDouble(),
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['lastUpdated'] ?? 0),
    );
  }
}
