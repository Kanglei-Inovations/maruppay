import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Background Aesthetic
          Positioned(
            top: -100,
            right: -100,
            child: _buildBlurCircle(const Color(0xFF10B981).withOpacity(0.15), 300),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: _buildBlurCircle(const Color(0xFFD4AF37).withOpacity(0.1), 250),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  _buildHeader(),
                  const Spacer(),
                  _buildLoginOptions(),
                  const SizedBox(height: 40),
                  _buildFooter(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          // Loading Overlay
          Obx(() => controller.isLoading.value 
            ? Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF10B981)),
                ),
              ) 
            : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildBlurCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    ).animate().fadeIn(duration: const Duration(seconds: 2));
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            // color: Colors.white10,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Image.asset('assets/logo.png', height: 100, errorBuilder: (c, e, s) => const Icon(Icons.account_balance_wallet, color: Color(0xFFD4AF37), size: 40)),
        ).animate().scale().fadeIn(),
        const SizedBox(height: 24),
        const Text(
          'Marup\nPay',
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ).animate().slideX(begin: -0.2).fadeIn(),
        const SizedBox(height: 12),
        const Text(
          'Community Savings & Digital Marup Platform',
          style: TextStyle(color: Colors.white60, fontSize: 16),
        ).animate().fadeIn(delay: const Duration(milliseconds: 400)),
      ],
    );
  }

  Widget _buildLoginOptions() {
    return Column(
      children: [
        _buildSocialButton(
          label: 'Continue with Google',
          icon: Icons.g_mobiledata,
          onPressed: () => controller.loginWithGoogle(),
        ).animate().slideY(begin: 0.5).fadeIn(delay: const Duration(milliseconds: 600)),
        // const SizedBox(height: 16),
        // _buildSocialButton(
        //   label: 'Phone OTP Login',
        //   icon: Icons.phone_android,
        //   isPrimary: false,
        //   onPressed: () {
        //     // Placeholder for OTP logic
        //     Get.snackbar('Coming Soon', 'OTP Login is being integrated.');
        //   },
        // ).animate().slideY(begin: 0.5).fadeIn(delay: const Duration(milliseconds: 800)),
      ],
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool isPrimary = true,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.white : Colors.transparent,
          foregroundColor: isPrimary ? Colors.black87 : Colors.white,
          shape: RoundedRectangleType(16),
          side: isPrimary ? BorderSide.none : const BorderSide(color: Colors.white24),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  RoundedRectangleBorder RoundedRectangleType(double radius) {
    return RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
  }

  Widget _buildFooter() {
    return const Center(
      child: Text.rich(
        TextSpan(
          text: 'By continuing, you agree to our ',
          children: [
            TextSpan(
              text: 'Terms of Service',
              style: TextStyle(color: Color(0xFFD4AF37), decoration: TextDecoration.underline),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white38, fontSize: 12),
      ),
    );
  }
}
