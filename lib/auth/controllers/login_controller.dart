import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';
import '../../core/app_color.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final obscurePassword = true.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> submitLogin(GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      final authController = AuthController.to;
      final error = await authController.loginUser(
        emailController.text.trim(),
        passwordController.text,
      );

      if (error != null) {
        Get.snackbar(
          'Login Failed',
          error,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColor.error,
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
          icon: const Icon(Icons.error_outline, color: Colors.white),
        );
      } else {
        Get.snackbar(
          'Success',
          'Logged in successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColor.success,
          colorText: Colors.black,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
          icon: const Icon(Icons.check_circle_outline, color: Colors.black),
        );
        Get.offAllNamed('/dashboard');
      }
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
