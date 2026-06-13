import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../routes/app_routes.dart';

class ProfileController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  final isLoading = false.obs;
  final currentUser = Rxn<UserModel>();

  // Hardcoded Admin Emails
  static const List<String> adminEmails = [
    'alaftabshah@gmail.com'
  ];

  @override
  void onInit() {
    super.onInit();
    // Listen to auth changes and fetch profile
    ever(_authService.user, (user) {
      if (user != null) {
        fetchProfile(user);
      } else {
        currentUser.value = null;
        // Only redirect to login if we aren't already there and aren't on splash
        if (Get.currentRoute != AppRoutes.login && Get.currentRoute != AppRoutes.initial) {
           Get.offAllNamed(AppRoutes.login);
        }
      }
    });
  }

  Future<void> fetchProfile(dynamic firebaseUser) async {
    // Bind currentUser to real-time stream from Firestore
    currentUser.bindStream(
      _firestoreService.documentStream(
        path: 'users/${firebaseUser.uid}',
        builder: (data, id) => UserModel.fromMap(data, id),
      ),
    );

    try {
      final userDoc = await _firestoreService.getDocument(
        path: 'users/${firebaseUser.uid}',
        builder: (data, id) => UserModel.fromMap(data, id),
      );
      
      if (userDoc != null) {
        // Update local cache
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_role', userDoc.role.name);
          await prefs.setBool('is_profile_complete', userDoc.isProfileComplete);
        } catch (_) {}

        // Update last login in Firestore
        await _firestoreService.updateData(
          path: 'users/${firebaseUser.uid}',
          data: {'lastLogin': DateTime.now().millisecondsSinceEpoch},
        );

        // Only redirect if the current dashboard doesn't match the required one
        _redirectIfNeeded(userDoc);
      } else {
        _handleNewUser(firebaseUser);
      }
    } catch (e) {
      _handleNewUser(firebaseUser);
    }
  }

  void _handleNewUser(dynamic firebaseUser) {
    bool isAdmin = adminEmails.contains(firebaseUser.email);
    if (Get.currentRoute != AppRoutes.profileSetup) {
      Get.offAllNamed(AppRoutes.profileSetup, arguments: {
        'role': isAdmin ? UserRole.superAdmin : UserRole.member
      });
    }
  }

  void _redirectIfNeeded(UserModel user) {
    final bool isAdmin = user.role == UserRole.admin || user.role == UserRole.superAdmin;
    final String targetRoute = isAdmin ? AppRoutes.adminDashboard : AppRoutes.memberDashboard;

    // 1. If profile is incomplete, force them to setup
    if (!user.isProfileComplete) {
      if (Get.currentRoute != AppRoutes.profileSetup) {
        Get.offAllNamed(AppRoutes.profileSetup);
      }
      return;
    }

    // 2. If profile is complete and we are on a transitional page, redirect to dashboard
    final List<String> transitionalRoutes = [
      AppRoutes.initial,
      AppRoutes.login,
      AppRoutes.splash,
      AppRoutes.profileSetup,
    ];

    if (transitionalRoutes.contains(Get.currentRoute)) {
      Get.offAllNamed(targetRoute);
    }
  }

  Future<void> completeProfile({
    required String fullName,
    required String mobileNumber,
    required String address,
    required String district,
    required UserRole role,
  }) async {
    isLoading.value = true;
    try {
      final firebaseUser = _authService.user.value!;
      
      final newUser = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email!,
        fullName: fullName,
        photoUrl: firebaseUser.photoURL,
        mobileNumber: mobileNumber,
        address: address,
        district: district,
        role: role,
        isProfileComplete: true,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      await _firestoreService.setData(
        path: 'users/${firebaseUser.uid}',
        data: newUser.toMap(),
      );

      // Update local cache
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', role.name);
        await prefs.setBool('is_profile_complete', true);
      } catch (_) {}

      currentUser.value = newUser;
      _redirectIfNeeded(newUser);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (_) {}
  }
}
