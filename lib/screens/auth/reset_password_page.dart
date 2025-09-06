import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/bindings/controller_ids.dart';
import 'package:frontend/controllers.dart/forgot_password_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final forgotPasswordController =
      Get.find<ForgotPasswordController>(tag: ControllerIds.forgotPassword);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await forgotPasswordController.resetPassword();
    if (success) {
      Fluttertoast.showToast(msg: 'Password reset successful!');
      Get.offAllNamed(AppRoutes.navigation, arguments: {
        'initialIndex': 2
      }); // Navigate to login page after success
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Obx(() => Column(
                children: [
                  // New Password
                  TextFormField(
                    controller: forgotPasswordController.passwordController,
                    obscureText: forgotPasswordController.obscurePassword.value,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          forgotPasswordController.obscurePassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () =>
                            forgotPasswordController.obscurePassword.value =
                                !forgotPasswordController.obscurePassword.value,
                      ),
                    ),
                    validator: (_) {
                      final pass = forgotPasswordController
                          .passwordController.text
                          .trim();
                      if (pass.isEmpty) return 'Please enter a new password';
                      if (pass.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Confirm Password
                  TextFormField(
                    controller:
                        forgotPasswordController.confirmPasswordController,
                    obscureText:
                        forgotPasswordController.obscureConfirmPassword.value,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          forgotPasswordController.obscureConfirmPassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => forgotPasswordController
                                .obscureConfirmPassword.value =
                            !forgotPasswordController
                                .obscureConfirmPassword.value,
                      ),
                    ),
                    validator: (_) {
                      final confirm = forgotPasswordController
                          .confirmPasswordController.text
                          .trim();
                      if (confirm.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (confirm !=
                          forgotPasswordController.passwordController.text
                              .trim()) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: forgotPasswordController.isLoading.value
                        ? null
                        : _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: forgotPasswordController.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Reset Password'),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
