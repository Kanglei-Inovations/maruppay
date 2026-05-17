import 'package:get/get.dart';
import '../models/winner_model.dart';

class LotteryController extends GetxController {
  final isDrawing = false.obs;
  final showWinnerReveal = false.obs;
  final currentWinner = Rxn<WinnerModel>();

  // Simulation of eligible members (Pot 1)
  final eligibleMembers = <String>[].obs;

  // Simulated lucky balls (Pot 2)
  final luckyBalls = List.generate(10, (index) => 'Ball ${index + 1}').obs;

  Future<void> startDraw(String groupId) async {
    isDrawing.value = true;
    showWinnerReveal.value = false;

    // 1. Lock entries and verify payments (Backend would do this)
    await Future.delayed(const Duration(seconds: 3));

    // 2. Select Winner (Secure selection via Cloud Functions simulation)
    // For the UI, we just simulate the delay for animation
    await Future.delayed(const Duration(seconds: 5));

    // Mock winner for animation demonstration
    currentWinner.value = WinnerModel(
      id: 'mock_win',
      groupId: groupId,
      userId: 'user_123',
      userName: 'John Doe',
      winningAmount: 50000,
      cycleNumber: 1,
      drawDate: DateTime.now(),
      luckyNumber: '7',
    );

    isDrawing.value = false;
    showWinnerReveal.value = true;
  }
}
