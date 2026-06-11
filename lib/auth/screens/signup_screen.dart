import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task/core/app_color.dart';
import 'package:task/core/app_strings.dart';
import '../controllers/auth_controller.dart';
import '../controllers/signup_controller.dart';
import 'widgets/widgets.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());
    final authController = AuthController.to;
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.background,
              AppColor.surface,
              AppColor.background,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      AppStrings.createAccount,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.signupSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Name Input
                    CustomTextField(
                      controller: controller.nameController,
                      labelText: AppStrings.Name,
                      prefixIcon: Icons.person_outline,
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppStrings.nameValidation;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Email Input
                    CustomTextField(
                      controller: controller.emailController,
                      labelText: AppStrings.Email,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppStrings.emailValidation;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Password Input
                    Obx(() {
                      return CustomTextField(
                        controller: controller.passwordController,
                        labelText: AppStrings.Password,
                        prefixIcon: Icons.lock_outlined,
                        isPassword: true,
                        obscureText: controller.obscurePassword.value,
                        onSuffixIconPressed: controller.togglePasswordVisibility,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.passwordValidation;
                          }
                          return null;
                        },
                      );
                    }),

                    const SizedBox(height: 32),

                    // Submit Button
                    Obx(() {
                      return PrimaryButton(
                        text: AppStrings.Sign_Up,
                        onPressed: () => controller.submitSignup(formKey),
                        isLoading: authController.isLoading.value,
                      );
                    }),
                    const SizedBox(height: 24),

                    // Redirect to Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.alreadyHaveAccount,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: const Text(
                            AppStrings.Sign_In,
                            style: TextStyle(
                              color: AppColor.primary,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
