import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Image.asset(
                'assets/logo.png',
                height: 100,
                errorBuilder: (c, e, s) => const Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.gold,
                  size: 80,
                ),
              ),
            ).animate().scale(duration: const Duration(milliseconds: 800), curve: Curves.elasticOut).fadeIn(),
            const SizedBox(height: 24),
            const Text(
              'KANGLEI MARUP',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ).animate().fadeIn(delay: const Duration(milliseconds: 400)).slideY(begin: 0.2),
            const SizedBox(height: 8),
            const Text(
              'Community Savings & Digital Platform',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ).animate().fadeIn(delay: const Duration(milliseconds: 600)),
            const SizedBox(height: 60),
            const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ).animate().fadeIn(delay: const Duration(milliseconds: 800)),
          ],
        ),
      ),
    );
  }
}
