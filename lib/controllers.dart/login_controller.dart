import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/bindings/controller_ids.dart';
import 'package:frontend/constants/app_strings.dart';
import 'package:frontend/data/models/user_model.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import 'package:frontend/controllers.dart/global_controller.dart';

class LoginController extends GetxController {
  static LoginController get to => Get.find();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final FocusNode usernameFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  RxBool obscureText = true.obs;
  RxBool isLoading = false.obs;

  RxBool isFormFilled = false.obs;

  final Dio dio = Dio(BaseOptions(baseUrl: StringAssets.baseUrl));
  final box = GetStorage();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final globalController =
      Get.find<GlobalController>(tag: ControllerIds.global);

  @override
  void onInit() {
    super.onInit();
    // globalController.loginPromptedOnce.value =
    //     box.read('loginPromptedOnce') ?? false;
    emailController.addListener(updateFormFilled);
    passwordController.addListener(updateFormFilled);
  }

  void toggleObscureText() {
    obscureText.value = !obscureText.value;
  }

  void updateFormFilled() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    isFormFilled.value = email.isNotEmpty && password.isNotEmpty;
  }

  Future<bool> loginUser() async {
    isLoading.value = true;

    try {
      final response = await dio.post(
        'v1/login/',
        data: {
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        final accessToken = data['accessToken'] ?? data['access'];
        final refreshToken = data['refreshToken'] ?? data['refresh'];

        if (accessToken != null && refreshToken != null) {
          // Store tokens securely using consistent keys
          await _secureStorage.write(key: 'access', value: accessToken);
          await _secureStorage.write(key: 'refresh', value: refreshToken);

          // Store login flag in GetStorage
          await box.write('isLoggedIn', true);

          final userJson = data['user'];
          if (userJson != null) {
            final user = UserModel.fromJson(userJson);
            globalController.currentUser.value = user;
            await box.write('user', user.toJson());
          }

          globalController.isLoggedIn.value = true;
          return true;
        } else {
          Get.snackbar('Login Failed', 'Missing tokens in response.');
        }
      } else {
        Get.snackbar('Login Failed', 'Invalid credentials or server error');
      }

      // Clear tokens & login flag on failure
      await _secureStorage.delete(key: 'access');
      await _secureStorage.delete(key: 'refresh');
      await box.remove('isLoggedIn');
      globalController.isLoggedIn.value = false;

      return false;
    } on DioException catch (e) {
      if (e.response != null) {
        Fluttertoast.showToast(
            msg: 'Response status: ${e.response?.statusCode}');
        Fluttertoast.showToast(msg: 'Response data: ${e.response?.data}');
      } else {
        Fluttertoast.showToast(msg: 'No response received');
      }

      String message = 'Login failed';
      if (e.response?.data != null) {
        // Sometimes API sends {"detail": "Invalid credentials"} or similar
        final data = e.response!.data;
        if (data is Map && data['detail'] != null) {
          message = data['detail'];
        } else if (data is String) {
          message = data;
        }
      }

      Get.snackbar('Error', message);
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Unexpected error occurred');

      // Clear tokens & login flag on failure
      await _secureStorage.delete(key: 'access');
      await _secureStorage.delete(key: 'refresh');
      await box.remove('isLoggedIn');
      globalController.isLoggedIn.value = false;

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> tryAutoLogin() async {
    final isLoggedInStored = box.read('isLoggedIn') ?? false;
    final accessToken = await _secureStorage.read(key: 'access');
    final refreshToken = await _secureStorage.read(key: 'refresh');
    final userMap = box.read('user');

    if (isLoggedInStored &&
        accessToken != null &&
        refreshToken != null &&
        userMap != null) {
      try {
        final user = UserModel.fromJson(Map<String, dynamic>.from(userMap));
        globalController.currentUser.value = user;
        globalController.accessToken.value = accessToken;
        globalController.refreshToken.value = refreshToken;
        globalController.isLoggedIn.value = true;
      } catch (e) {
        globalController.isLoggedIn.value = false;
      }
    } else {
      globalController.isLoggedIn.value = false;
    }
  }
}
