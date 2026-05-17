import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../controllers/lottery_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/responsive_sidebar.dart';
import '../../routes/app_routes.dart';

class LotteryDrawView extends GetView<LotteryController> {
  const LotteryDrawView({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return Scaffold(
      body: Row(
        children: [
          if (!isMobile) const MemberSidebar(activeRoute: AppRoutes.lottery),
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.black,
              body: Stack(
                children: [
                  // Dark Gradient Background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.5,
                        colors: [Color(0xFF1B5E20), Colors.black],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Column(
                          children: [
                            const SizedBox(height: 32),
                            Text(
                              'LIVE MARUP DRAW',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: AppColors.accent,
                                    letterSpacing: 4,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2000.ms),
                            const Spacer(),
                            // 2-POT System Visualization
                            Obx(
                              () => Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildPot(
                                    context,
                                    label: 'POT 1: ELIGIBLE',
                                    icon: Icons.people,
                                    isSpinning: controller.isDrawing.value,
                                  ),
                                  _buildPot(
                                    context,
                                    label: 'POT 2: LUCKY BALLS',
                                    icon: Icons.stars,
                                    isSpinning: controller.isDrawing.value,
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Obx(() {
                              if (controller.showWinnerReveal.value) {
                                return _buildWinnerReveal(context, controller);
                              }
                              return _buildDrawButton(controller);
                            }),
                            const SizedBox(height: 48),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPot(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSpinning,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.5),
              width: 2,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.1),
                Colors.transparent,
              ],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rotating Gems/Balls simulation
              for (int i = 0; i < 8; i++) _buildRotatingBall(i, isSpinning),

              Icon(
                icon,
                color: AppColors.primary.withValues(alpha: 0.3),
                size: 60,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRotatingBall(int index, bool isSpinning) {
    final random = Random();
    return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          child: Icon(
            Icons.circle,
            size: 12,
            color: [
              Colors.green,
              const Color(0xFFFFD700),
              Colors.white,
            ][random.nextInt(3)].withValues(alpha: 0.6),
          ),
        )
        .animate(onPlay: (c) => isSpinning ? c.repeat() : c.stop())
        .custom(
          duration: (1000 + (index * 200)).ms,
          builder: (context, value, child) {
            final angle = value * 2 * pi;
            return Transform.translate(
              offset: Offset(cos(angle) * 50, sin(angle) * 50),
              child: child,
            );
          },
        );
  }

  Widget _buildDrawButton(LotteryController controller) {
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: ElevatedButton(
            onPressed: controller.isDrawing.value
                ? null
                : () => controller.startDraw('group_123'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 20),
            ),
            child: Text(
              controller.isDrawing.value ? 'DRAWING...' : 'START DRAW',
            ),
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(color: AppColors.primary.withValues(alpha: 0.5));
  }

  Widget _buildWinnerReveal(
    BuildContext context,
    LotteryController controller,
  ) {
    final winner = controller.currentWinner.value!;
    return Column(
      children: [
        const Text(
          'WE HAVE A WINNER!',
          style: TextStyle(
            color: AppColors.accent,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.accent, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.3),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                winner.userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'WON ₹${winner.winningAmount}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'LUCKY NUMBER: ${winner.luckyNumber}',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn().scale(delay: 300.ms, curve: Curves.easeOutBack),

        const SizedBox(height: 32),

        ElevatedButton(
          onPressed: () => Get.back(),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white10),
          child: const Text('CLOSE'),
        ),
      ],
    );
  }
}
