import 'package:get/get.dart';
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
        Get.offAllNamed(AppRoutes.login);
      }
    });
  }

  Future<void> fetchProfile(dynamic firebaseUser) async {
    try {
      final userDoc = await _firestoreService.getDocument(
        path: 'users/${firebaseUser.uid}',
        builder: (data, id) => UserModel.fromMap(data, id),
      );
      
      currentUser.value = userDoc;
      
      // Update last login
      await _firestoreService.updateData(
        path: 'users/${firebaseUser.uid}',
        data: {'lastLogin': DateTime.now().millisecondsSinceEpoch},
      );

      _redirectUser(userDoc);
    } catch (e) {
      // User doc doesn't exist, handle new user or incomplete profile
      _handleNewUser(firebaseUser);
    }
  }

  void _handleNewUser(dynamic firebaseUser) {
    // Check if email is in admin list
    bool isAdmin = adminEmails.contains(firebaseUser.email);
    
    if (isAdmin) {
      // Create initial admin doc or redirect to setup with admin role
      Get.offAllNamed(AppRoutes.profileSetup, arguments: {'role': UserRole.superAdmin});
    } else {
      Get.offAllNamed(AppRoutes.profileSetup, arguments: {'role': UserRole.member});
    }
  }

  void _redirectUser(UserModel user) {
    if (!user.isProfileComplete) {
      Get.offAllNamed(AppRoutes.profileSetup);
      return;
    }

    if (user.role == UserRole.admin || user.role == UserRole.superAdmin) {
      Get.offAllNamed(AppRoutes.adminDashboard);
    } else {
      Get.offAllNamed(AppRoutes.memberDashboard);
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

      currentUser.value = newUser;
      _redirectUser(newUser);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save profile: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
