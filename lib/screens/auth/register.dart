import 'package:flutter/material.dart';
import 'package:frontend/bindings/controller_ids.dart';
import 'package:frontend/controllers.dart/global_controller.dart';
import 'package:frontend/controllers.dart/register_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/utils/validators.dart';
import 'package:frontend/widgets/common_widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final registerController =
      Get.find<RegisterController>(tag: ControllerIds.register);
  final globalController =
      Get.find<GlobalController>(tag: ControllerIds.global);
  final box = GetStorage();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    registerController.updateFormFilled();
  }

  void _skip() async {
    await globalController.skipLoginRegiser();
    Get.offAllNamed(AppRoutes.navigation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Create Account',
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),

                        // Name field
                        commonTextField(
                          from: 'register',
                          label: 'Name',
                          controller: registerController.nameController,
                          validator: validateName,
                          focusNode: registerController.nameFocusNode,
                          context: context,
                        ),

                        // Email field
                        commonTextField(
                          context: context,
                          label: 'Email',
                          controller: registerController.emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) {
                            final formatError = validateEmail(val);
                            if (formatError != null) return formatError;
                            return null;
                          },
                          onChanged: (_) {
                            registerController.updateFormFilled();
                          },
                          from: 'register',
                          focusNode: registerController.emailFocusNode,
                        ),

                        // Password field with show/hide toggle
                        Obx(() => commonTextField(
                              context: context,
                              focusNode: registerController.passwordFocusNode,
                              from: 'register',
                              label: 'Password',
                              controller: registerController.passwordController,
                              obscureText:
                                  registerController.obscureTextPassword.value,
                              validator: validatePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  registerController.obscureTextPassword.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  registerController.obscureTextPassword.value =
                                      !registerController
                                          .obscureTextPassword.value;
                                },
                                tooltip:
                                    registerController.obscureTextPassword.value
                                        ? 'Show password'
                                        : 'Hide password',
                              ),
                            )),

                        const SizedBox(height: 10),

                        // Confirm Password field with show/hide toggle
                        Obx(() => commonTextField(
                              context: context,
                              focusNode:
                                  registerController.confirmPasswordFocusNode,
                              from: 'register',
                              label: 'Confirm Password',
                              controller:
                                  registerController.confirmPasswordController,
                              obscureText: registerController
                                  .obscureTextConfirmPassword.value,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (val !=
                                    registerController
                                        .passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                              suffixIcon: IconButton(
                                icon: Icon(registerController
                                        .obscureTextConfirmPassword.value
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () {
                                  registerController
                                          .obscureTextConfirmPassword.value =
                                      !registerController
                                          .obscureTextConfirmPassword.value;
                                },
                                tooltip: registerController
                                        .obscureTextConfirmPassword.value
                                    ? 'Show confirm password'
                                    : 'Hide confirm password',
                              ),
                            )),

                        const SizedBox(height: 20),

                        // Register button with loading indicator and enabled/disabled state
                        Obx(() => ElevatedButton(
                              onPressed:
                                  registerController.isFormFilled.value &&
                                          !registerController.isLoading.value
                                      ? _submit
                                      : null,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: registerController.isLoading.value
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Register',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            )),

                        const SizedBox(height: 15),

                        // Link to login page
                        TextButton(
                          onPressed: () async {
                            await box.write('registerPromptedOnce', true);
                            globalController.registerPromptedOnce.value = true;
                            Get.back();
                          },
                          child: const Text("Already have an account? Login"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Skip button shown conditionally
              if (globalController.registerPromptedOnce.value == false &&
                  globalController.loginPromptedOnce.value == false)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Semantics(
                    button: true,
                    child: TextButton(
                      onPressed: _skip,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      Get.dialog(
        WillPopScope(
          onWillPop: () async => false,
          child: const Center(child: CircularProgressIndicator()),
        ),
        barrierDismissible: false,
      );

      final email = registerController.emailController.text.trim();

      final isRegistered = await registerController.isEmailRegistered(email);

      if (Get.isDialogOpen ?? false) Get.back();

      if (!isRegistered) {
        // Request OTP and start timer
        final otpSent = await registerController.requestOtpAndStartTimer(email);

        if (otpSent) {
          // Navigate to OTP verification page with required arguments
          Get.toNamed(
            AppRoutes.registerOtpVerification,
            arguments: {
              'email': email,
              'name': registerController.nameController.text.trim(),
              'password': registerController.passwordController.text.trim(),
            },
          );
        } else {
          Get.snackbar(
            'Error',
            'Failed to send OTP. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade600,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Email already registered. Please login or use a different email.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
        );
      }
    }
  }
}
