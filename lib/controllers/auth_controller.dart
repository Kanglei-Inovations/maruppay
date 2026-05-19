import 'package:get/get.dart';
import '../services/auth_service.dart';
import 'profile_controller.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final isLoading = false.obs;

  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    try {
      await _authService.signInWithGoogle();
      // Redirection is handled by ProfileController's 'ever' listener on auth state
    } catch (e) {
      Get.snackbar('Login Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await Get.find<ProfileController>().clearCache();
    await _authService.signOut();
  }
}
