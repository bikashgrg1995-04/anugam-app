import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/bindings/controller_ids.dart';
import 'package:frontend/data/models/user_model.dart';
import 'package:frontend/data/providers/dio_service.dart';
import 'package:frontend/controllers.dart/global_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart' as dio; // alias dio

class ProfileController extends GetxController {
  static ProfileController get to => Get.find(tag: ControllerIds.profile);

  // User state (single source of truth for ProfileScreen)
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  final globalController =
      Get.find<GlobalController>(tag: ControllerIds.global);

  final box = GetStorage();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Password controllers
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;

  final isCurrentPasswordHidden = true.obs;
  final isNewPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;

  final RxBool isUserInfoExpanded = false.obs;

  // Profile pic states
  var tempProfilePic = RxnString();
  var isUploadingProfilePic = false.obs;
  var profileUploadProgress = 0.0.obs;

  // Cover pic states
  var tempCoverPic = RxnString();
  var isUploadingCoverPic = false.obs;
  var coverUploadProgress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize from saved user in globalController
    currentUser.value = globalController.currentUser.value;
  }

  /// Update user info with optional image uploads
  Future<void> updateUserInfo({
    String? phone,
    String? email,
    String? location,
    String? gender,
    String? dateOfBirth,
    String? profilePicPath,
    String? coverPicPath,
  }) async {
    if (profilePicPath == null &&
        coverPicPath == null &&
        phone == null &&
        email == null &&
        location == null &&
        gender == null &&
        dateOfBirth == null) {
      Fluttertoast.showToast(msg: "No data to update");
      return;
    }

    final formData = dio.FormData();

    if (phone != null) formData.fields.add(MapEntry('phone', phone));
    if (email != null) formData.fields.add(MapEntry('email', email));
    if (location != null) formData.fields.add(MapEntry('location', location));
    if (gender != null) formData.fields.add(MapEntry('gender', gender));
    if (dateOfBirth != null) {
      formData.fields.add(MapEntry('date_of_birth', dateOfBirth));
    }

    if (profilePicPath != null) {
      formData.files.add(
        MapEntry(
          'profile_pic',
          await dio.MultipartFile.fromFile(
            profilePicPath,
            filename: profilePicPath.split('/').last,
          ),
        ),
      );
    }

    if (coverPicPath != null) {
      formData.files.add(
        MapEntry(
          'cover_pic',
          await dio.MultipartFile.fromFile(
            coverPicPath,
            filename: coverPicPath.split('/').last,
          ),
        ),
      );
    }

    try {
      if (profilePicPath != null) isUploadingProfilePic.value = true;
      if (coverPicPath != null) isUploadingCoverPic.value = true;

      final response = await DioService.dio.patch(
        'v1/user/update/',
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0) {
            final progress = (sent / total) * 100;
            if (profilePicPath != null) profileUploadProgress.value = progress;
            if (coverPicPath != null) coverUploadProgress.value = progress;
          }
        },
        options: dio.Options(
          headers: {'Content-Type': 'multipart/form-data'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final updatedUser = UserModel.fromJson(response.data['data']);

        // ✅ update ProfileController only (avoid loop with GlobalController)
        currentUser.value = updatedUser;
        globalController.currentUser.value = updatedUser;
        await box.write('user', response.data['data']);

        // Clear temp previews after updating state
        if (profilePicPath != null) tempProfilePic.value = null;
        if (coverPicPath != null) tempCoverPic.value = null;

        Fluttertoast.showToast(msg: "Profile updated successfully");
      } else {
        Fluttertoast.showToast(
          msg:
              "Update failed: ${response.statusCode} - ${response.data?['detail'] ?? 'Unknown error'}",
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error updating profile: $e");
    } finally {
      isUploadingProfilePic.value = false;
      isUploadingCoverPic.value = false;
      profileUploadProgress.value = 0;
      coverUploadProgress.value = 0;
    }
  }

  /// Logout user from API and local
  Future<void> logoutUser() async {
    await _logoutFromApi();
    await _performLocalLogout();
  }

  Future<void> _logoutFromApi() async {
    try {
      final refreshToken = await _secureStorage.read(key: 'refresh');
      if (refreshToken == null || refreshToken.isEmpty) return;

      await DioService.dio.post(
        'v1/logout/',
        data: {'refresh': refreshToken},
        options:
            Options(validateStatus: (status) => status != null && status < 500),
      );
    } catch (_) {}
  }

  Future<void> _performLocalLogout() async {
    await _secureStorage.delete(key: 'access');
    await _secureStorage.delete(key: 'refresh');
    await box.remove('user');
    await box.write('isLoggedIn', false);

    currentUser.value = null;
    globalController.isLoggedIn.value = false;

    Get.offAllNamed(AppRoutes.navigation, arguments: {'initialIndex': 2});
  }

  /// Fetch user profile
  Future<void> fetchProfile() async {
    try {
      final response = await DioService.dio.get('v1/profile/');
      if (response.statusCode == 200 && response.data != null) {
        final userData = response.data['data'];
        final userModel = UserModel.fromJson(userData);

        currentUser.value = userModel;
        await box.write('user', userData);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error fetching profile: $e');
    }
  }

  /// Change password
  Future<void> changePassword() async {
    try {
      final response = await DioService.dio.post(
        'v1/user/change-password/',
        data: {
          'current_password': currentPasswordController.text.trim(),
          'new_password': newPasswordController.text.trim(),
        },
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: 'Password changed successfully');
        Get.back();
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error changing password: $e');
    }
  }

  // Convenience methods
  Future<void> updateProfilePic(String filePath) async {
    await updateUserInfo(profilePicPath: filePath);
  }

  Future<void> updateCoverPic(String filePath) async {
    await updateUserInfo(coverPicPath: filePath);
  }
}
