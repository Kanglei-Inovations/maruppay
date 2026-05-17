import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../controllers/profile_controller.dart';
import '../controllers/auth_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(FirestoreService());
    Get.put(AuthService());
    Get.put(ProfileController());
    Get.put(AuthController());
  }
}
