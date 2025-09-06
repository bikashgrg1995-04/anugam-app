import 'package:flutter/material.dart';
import 'package:frontend/data/providers/dio_service.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  //otp screen
  final emailController = TextEditingController();
  final otpController = TextEditingController();

  final otpSent = false.obs;

  //password screen
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  RxBool obscurePassword = true.obs;
  RxBool obscureConfirmPassword = true.obs;

  final FocusNode emailFocusNode = FocusNode();
  final FocusNode otpFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();

  final isLoading = false.obs;

  Future<bool> sendOtpToEmail() async {
    isLoading.value = true;
    try {
      final response = await DioService.dio.post(
        'v1/request-reset-password-otp/',
        data: {'email': emailController.text.trim()},
      );

      if (response.statusCode == 200) {
        otpSent.value = true;
        Get.snackbar('Success', 'OTP sent to your email');
        return true;
      } else {
        Get.snackbar('Error', 'Failed to send OTP');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Error sending OTP');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyOtp() async {
    isLoading.value = true;
    try {
      final response = await DioService.dio.post(
        'v1/verify-reset-password-otp/',
        data: {
          'email': emailController.text.trim(),
          'otp_code': otpController.text.trim(),
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar(
            'Verified', 'OTP verified. You can now reset your password.');
        return true;
      } else {
        Get.snackbar('Error', 'OTP verification failed');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Error verifying OTP');

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  bool validatePasswords() {
    final pass = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    if (pass.isEmpty || confirm.isEmpty) {
      Get.snackbar('Error', 'Password fields cannot be empty');
      return false;
    }
    if (pass.length < 6) {
      Get.snackbar('Error', 'Password must be at least 6 characters');
      return false;
    }
    if (pass != confirm) {
      Get.snackbar('Error', 'Passwords do not match');
      return false;
    }
    return true;
  }

  Future<bool> resetPassword() async {
    if (!validatePasswords()) return false;

    isLoading.value = true;
    try {
      final response = await DioService.dio.post(
        'v1/reset-password/',
        data: {
          'email': emailController.text.trim(),
          'new_password': passwordController.text.trim(),
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Password reset successful');
        return true;
      } else {
        Get.snackbar('Error', 'Failed to reset password');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Error resetting password');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
