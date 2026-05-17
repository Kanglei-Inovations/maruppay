import 'package:get/get.dart';
import '../views/auth/login_view.dart';
import '../views/auth/profile_setup_view.dart';
import '../views/member/member_dashboard.dart';
import '../views/admin/admin_dashboard.dart';
import '../views/wallet/wallet_view.dart';
import '../views/lottery/lottery_draw_view.dart';
import '../views/settings/settings_view.dart';
import '../controllers/wallet_controller.dart';
import '../controllers/group_controller.dart';
import '../controllers/lottery_controller.dart';
import 'auth_middleware.dart';

class AppRoutes {
  static const String initial = '/';
  static const String login = '/login';
  static const String profileSetup = '/profile-setup';
  static const String memberDashboard = '/member-dashboard';
  static const String adminDashboard = '/admin-dashboard';
  static const String wallet = '/wallet';
  static const String lottery = '/lottery';
  static const String settings = '/settings';

  static List<GetPage> routes = [
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
        Get.lazyPut<LotteryController>(() => LotteryController(), fenix: true);
      }),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: adminDashboard,
      page: () => const AdminDashboard(),
      binding: BindingsBuilder(() {
        Get.lazyPut<GroupController>(() => GroupController());
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
      page: () => const LotteryDrawView(),
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
  ];
}
