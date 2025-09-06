import 'dart:async';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/constants/app_strings.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class RegisterController extends GetxController {
  static RegisterController get to => Get.find();

  // Text Controllers for form fields
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final otpController = TextEditingController();

  // Focus Nodes for field focus management
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();

  // Observable states for UI updates
  RxBool obscureTextPassword = true.obs;
  RxBool obscureTextConfirmPassword = true.obs;
  RxBool isLoading = false.obs;
  RxBool isFormFilled = false.obs;

  // Resend OTP timer management
  RxInt resendSecondsLeft = 0.obs;
  Timer? _resendTimer;

  // Dio instance for API calls with baseUrl
  final Dio dio = Dio(BaseOptions(baseUrl: StringAssets.baseUrl));

  @override
  void onInit() {
    super.onInit();

    // Listen to text changes to update form filled state reactively
    nameController.addListener(updateFormFilled);
    emailController.addListener(updateFormFilled);
    passwordController.addListener(updateFormFilled);
    confirmPasswordController.addListener(updateFormFilled);
  }

  // Update isFormFilled to true only if all required fields are non-empty
  void updateFormFilled() {
    isFormFilled.value = nameController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        passwordController.text.trim().isNotEmpty &&
        confirmPasswordController.text.trim().isNotEmpty;
  }

  // Check if password and confirm password fields match
  bool validatePasswordsMatch() {
    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      Fluttertoast.showToast(msg: "Passwords do not match");
      return false;
    }
    return true;
  }

  /// Check if email is already registered
  Future<bool> isEmailRegistered(String email) async {
    try {
      final response = await dio.get(
        'v1/check-email/',
        queryParameters: {'email': email},
      );

      print("Email check response: ${response.data}");
      print("Status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        return response.data['exists'] == true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Start or restart the resend OTP cooldown timer (default 60 seconds)
  void startResendTimer({int seconds = 60}) {
    _resendTimer?.cancel();
    resendSecondsLeft.value = seconds;

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSecondsLeft.value > 0) {
        resendSecondsLeft.value--;
      } else {
        timer.cancel();
      }
    });
  }

  // True if user can request OTP (cooldown finished)
  bool get canRequestOtp => resendSecondsLeft.value == 0;

  /// Sends OTP request to backend.
  /// Returns true if OTP was sent successfully, else false.
  /// Requests OTP and starts the resend timer if successful
  Future<bool> requestOtpAndStartTimer(String email) async {
    if (!validatePasswordsMatch()) return false;

    if (!canRequestOtp) {
      Fluttertoast.showToast(
        msg:
            "Please wait ${resendSecondsLeft.value}s before requesting OTP again",
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      return false;
    }

    isLoading.value = true;
    try {
      final response = await dio.post(
        'v1/request-register-otp/',
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "OTP sent to $email");
        startResendTimer();
        return true;
      } else {
        Fluttertoast.showToast(
          msg: response.data['message'] ?? 'Failed to send OTP',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error sending OTP: ${e.toString()}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Verifies the OTP and registers the user.
  /// Returns true if successful, else false.
  Future<bool> verifyOtpAndRegister({
    required String email,
    required String otpCode,
    required String name,
    required String password,
  }) async {
    isLoading.value = true;
    try {
      // 1. Verify OTP
      final verifyResponse = await dio.post(
        'v1/verify-register-otp/',
        data: {'email': email, 'otp_code': otpCode},
      );

      // Print debug info
      print('OTP verify response status: ${verifyResponse.statusCode}');
      print('OTP verify response data: ${verifyResponse.data}');

      if (verifyResponse.statusCode != 200) {
        final errorMsg = verifyResponse.data['error'] ??
            verifyResponse.data['message'] ??
            'Invalid OTP or verification failed.';
        Fluttertoast.showToast(
          msg: errorMsg,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return false;
      }

      // 2. Register user
      final registerResponse = await dio.post(
        'v1/register/',
        data: {
          'email': email,
          'password': password,
          'full_name': name,
          'otp_code': otpCode,
        },
      );

      print('Register response status: ${registerResponse.statusCode}');
      print('Register response data: ${registerResponse.data}');

      if (registerResponse.statusCode == 201 ||
          registerResponse.statusCode == 200) {
        Fluttertoast.showToast(msg: "Registration successful! Please log in.");
        return true;
      } else {
        final errorMsg =
            registerResponse.data['message'] ?? 'Registration failed';
        Fluttertoast.showToast(
          msg: errorMsg,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return false;
      }
    } on DioError catch (dioError) {
      // Dio error info (e.g. network, server errors)
      final errorResponse = dioError.response;
      final errorMsg = errorResponse?.data?['error'] ??
          errorResponse?.data?['message'] ??
          dioError.message;

      Fluttertoast.showToast(
        msg: "Error: $errorMsg",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      print('Dio error: ${dioError.toString()}');
      return false;
    } catch (e) {
      // Other errors
      Fluttertoast.showToast(
        msg: "Unexpected error: ${e.toString()}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      print('Unexpected error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _resendTimer?.cancel();

    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    nameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();

    super.onClose();
  }
}
