import 'package:get/get.dart';
import '../views/auth/splash_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/profile_setup_view.dart';
import '../views/member/member_dashboard.dart';
import '../views/admin/admin_dashboard.dart';
import '../views/admin/admin_group_members_view.dart';
import '../views/wallet/wallet_view.dart';
import '../views/lottery/lottery_draw_view.dart';
import '../views/settings/settings_view.dart';
import '../views/settings/test_utility_view.dart';
import '../controllers/wallet_controller.dart';
import '../controllers/group_controller.dart';
import '../controllers/lottery_controller.dart';
import '../controllers/test_utility_controller.dart';
import '../controllers/admin_group_members_controller.dart';
import '../controllers/admin_controller.dart';
import '../controllers/admin_draw_controller.dart';
import 'auth_middleware.dart';

class AppRoutes {
  static const String initial = '/';
  static const String splash = '/splash';
  static const String login = '/login';
  static const String profileSetup = '/profile-setup';
  static const String memberDashboard = '/member-dashboard';
  static const String adminDashboard = '/admin-dashboard';
  static const String adminMembers = '/admin-group-members';
  static const String wallet = '/wallet';
  static const String lottery = '/lottery';
  static const String settings = '/settings';
  static const String testUtility = '/test-utility';

  static List<GetPage> routes = [
    GetPage(
      name: initial,
      page: () => const SplashView(),
    ),
    GetPage(
      name: login,
      page: () => const LoginView(),
    ),
    GetPage(
      name: profileSetup,
      page: () => const ProfileSetupView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: memberDashboard,
      page: () => const MemberDashboard(),
      binding: BindingsBuilder(() {
        Get.lazyPut<WalletController>(() => WalletController());
        Get.lazyPut<GroupController>(() => GroupController());
        Get.lazyPut<LotteryController>(() => LotteryController(), fenix: true);
      }),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: adminDashboard,
      page: () => const AdminDashboard(),
      binding: BindingsBuilder(() {
        Get.lazyPut<GroupController>(() => GroupController());
        Get.lazyPut<AdminController>(() => AdminController());
        Get.lazyPut<AdminDrawController>(() => AdminDrawController());
      }),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: adminMembers,
      page: () => const AdminGroupMembersView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AdminGroupMembersController>(() => AdminGroupMembersController());
      }),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: wallet,
      page: () => const WalletView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<WalletController>(() => WalletController());
      }),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: lottery,
      page: () {
        final drawId = Get.parameters['drawId'] ?? '';
        final groupId = Get.parameters['groupId'] ?? '';
        return LotteryDrawView(drawId: drawId, groupId: groupId);
      },
      binding: BindingsBuilder(() {
        Get.lazyPut<LotteryController>(() => LotteryController());
      }),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: settings,
      page: () => const SettingsView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: testUtility,
      page: () => const TestUtilityView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<TestUtilityController>(() => TestUtilityController());
      }),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
