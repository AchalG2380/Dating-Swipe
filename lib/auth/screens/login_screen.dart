import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task/core/app_strings.dart';
import 'package:task/core/app_color.dart';
import '../controllers/auth_controller.dart';
import '../controllers/login_controller.dart';
import 'widgets/widgets.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    final authController = AuthController.to;
    final formKey = GlobalKey<FormState>();

    return Scaffold(
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
                    // Brand Icon & Welcome Title
                    Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColor.primary, Colors.deepOrangeAccent],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.primary.withValues(alpha: 0.3),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      AppStrings.Welcome,
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
                      AppStrings.loginSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Email Input Container
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

                    // Password Input Container
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
                        text: AppStrings.Sign_In,
                        onPressed: () => controller.submitLogin(formKey),
                        isLoading: authController.isLoading.value,
                      );
                    }),
                    const SizedBox(height: 24),

                    // Redirect to Registration
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.dontHaveAccount,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.toNamed('/register');
                          },
                          child: const Text(
                            AppStrings.Sign_Up,
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
