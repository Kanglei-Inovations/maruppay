enum UserRole { member, admin, superAdmin }

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String? photoUrl;
  final String mobileNumber;
  final String address;
  final String district;
  final UserRole role;
  final double walletBalance;
  final List<String> joinedGroups;
  final bool isProfileComplete;
  final String kycStatus; // pending, verified, rejected
  final bool isActive;
  final DateTime createdAt;
  final DateTime lastLogin;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    this.photoUrl,
    required this.mobileNumber,
    required this.address,
    required this.district,
    this.role = UserRole.member,
    this.walletBalance = 0.0,
    this.joinedGroups = const [],
    this.isProfileComplete = false,
    this.kycStatus = 'pending',
    this.isActive = true,
    required this.createdAt,
    required this.lastLogin,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'photoUrl': photoUrl,
      'mobileNumber': mobileNumber,
      'address': address,
      'district': district,
      'role': role.name,
      'walletBalance': walletBalance,
      'joinedGroups': joinedGroups,
      'isProfileComplete': isProfileComplete,
      'kycStatus': kycStatus,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLogin': lastLogin.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      photoUrl: map['photoUrl'],
      mobileNumber: map['mobileNumber'] ?? '',
      address: map['address'] ?? '',
      district: map['district'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.member,
      ),
      walletBalance: (map['walletBalance'] ?? 0.0).toDouble(),
      joinedGroups: List<String>.from(map['joinedGroups'] ?? []),
      isProfileComplete: map['isProfileComplete'] ?? false,
      kycStatus: map['kycStatus'] ?? 'pending',
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      lastLogin: DateTime.fromMillisecondsSinceEpoch(
        map['lastLogin'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  UserModel copyWith({
    String? fullName,
    String? photoUrl,
    String? mobileNumber,
    String? address,
    String? district,
    UserRole? role,
    double? walletBalance,
    List<String>? joinedGroups,
    bool? isProfileComplete,
    String? kycStatus,
    bool? isActive,
    DateTime? lastLogin,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      fullName: fullName ?? this.fullName,
      photoUrl: photoUrl ?? this.photoUrl,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      address: address ?? this.address,
      district: district ?? this.district,
      role: role ?? this.role,
      walletBalance: walletBalance ?? this.walletBalance,
      joinedGroups: joinedGroups ?? this.joinedGroups,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      kycStatus: kycStatus ?? this.kycStatus,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
