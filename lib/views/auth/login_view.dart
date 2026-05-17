import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/app_colors.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    _buildHeader(context),
                    const Spacer(),
                    _buildLoginSection(),
                    const SizedBox(height: 48),
                    _buildFooter(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.05),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withOpacity(0.05),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.account_balance_wallet, size: 35, color: Colors.white),
        ).animate().fadeIn().slideX(begin: -0.5),
        const SizedBox(height: 32),
        Text(
          'Manage your savings,\nSmartly.',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
        const SizedBox(height: 12),
        const Text(
          'The most secure community savings platform.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  Widget _buildLoginSection() {
    return Column(
      children: [
        _buildLoginButton(
          label: 'Continue with Google',
          icon: Icons.login_rounded,
          onTap: () => controller.loginWithGoogle(),
          isPrimary: true,
        ),
      ],
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildLoginButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = true,
  }) {
    return Obx(() => ElevatedButton(
      onPressed: controller.isLoading.value ? null : onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20),
        backgroundColor: isPrimary ? AppColors.primary : Colors.white,
        foregroundColor: isPrimary ? Colors.white : AppColors.textPrimary,
        elevation: isPrimary ? 2 : 0,
        side: isPrimary ? null : const BorderSide(color: AppColors.border),
      ),
      child: controller.isLoading.value
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
    ));
  }

  Widget _buildFooter(BuildContext context) {
    return const Center(
      child: Column(
        children: [
          Text(
            'Secured by Google Firebase',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          SizedBox(height: 8),
          Text(
            'Terms of Service • Privacy Policy',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
