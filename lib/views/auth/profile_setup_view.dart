import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/profile_controller.dart';
import '../../theme/app_colors.dart';
import '../../models/user_model.dart';

class ProfileSetupView extends StatefulWidget {
  const ProfileSetupView({super.key});

  @override
  State<ProfileSetupView> createState() => _ProfileSetupViewState();
}

class _ProfileSetupViewState extends State<ProfileSetupView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _districtController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    final role = Get.arguments?['role'] ?? UserRole.member;

    return Scaffold(
      appBar: AppBar(
        title: Text('Setup ${role == UserRole.member ? "Member" : "Admin"} Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complete your profile',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ).animate().fadeIn().slideY(begin: -0.2),
                  const SizedBox(height: 8),
                  Text(
                    'You are setting up an ${role.toString().split('.').last.toUpperCase()} account.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.primary),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 32),
                  _buildField(
                    label: 'Full Name',
                    controller: _nameController,
                    icon: Icons.person_outline,
                    validator: (v) => v!.isEmpty ? 'Enter your name' : null,
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 16),
                  _buildField(
                    label: 'Mobile Number',
                    controller: _phoneController,
                    icon: Icons.phone_android_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.length < 10 ? 'Enter valid number' : null,
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 16),
                  _buildField(
                    label: 'District',
                    controller: _districtController,
                    icon: Icons.location_city_outlined,
                    validator: (v) => v!.isEmpty ? 'Enter district' : null,
                  ).animate().fadeIn(delay: 500.ms),
                  const SizedBox(height: 16),
                  _buildField(
                    label: 'Full Address',
                    controller: _addressController,
                    icon: Icons.home_outlined,
                    maxLines: 3,
                    validator: (v) => v!.isEmpty ? 'Enter address' : null,
                  ).animate().fadeIn(delay: 600.ms),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  controller.completeProfile(
                                    fullName: _nameController.text,
                                    mobileNumber: _phoneController.text,
                                    address: _addressController.text,
                                    district: _districtController.text,
                                    role: role,
                                  );
                                }
                              },
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Save & Continue'),
                      ),
                    ),
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary),
            hintText: 'Enter $label',
          ),
        ),
      ],
    );
  }
}
