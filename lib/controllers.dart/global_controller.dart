import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/constants/app_assets.dart';
import 'package:frontend/constants/app_colors.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:frontend/constants/app_strings.dart';
import 'package:frontend/bindings/controller_ids.dart';
import 'package:frontend/controllers.dart/login_controller.dart';
import 'package:frontend/controllers.dart/profile_controller.dart';
import 'package:frontend/data/models/user_model.dart';
import 'package:frontend/onboarding_screen.dart';
import 'package:frontend/screens/auth/login.dart';
import 'package:frontend/screens/discover_screen.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/navigation_page.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:image_picker/image_picker.dart';

class GlobalController extends GetxController {
  static GlobalController get to => Get.find();

  // Reactive vars
  var appName = StringAssets.appName.obs;
  var isConnected = true.obs;

  RxBool seenOnboarding = false.obs;

  RxBool loginPromptedOnce = false.obs;
  RxBool registerPromptedOnce = false.obs;

  RxBool isLoggedIn = false.obs;
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  RxnString accessToken = RxnString(null);
  RxnString refreshToken = RxnString(null);

  final GetStorage _storage = GetStorage();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Reactive file picker
  Rxn<File> pickedFile = Rxn<File>(null); // holds selected file

  late Dio dio;
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _initData();
    _initDio();
  }

  Future<void> _initData() async {
    // Load tokens from secure storage asynchronously
    accessToken.value = await _secureStorage.read(key: 'accessToken');
    refreshToken.value = await _secureStorage.read(key: 'refreshToken');

    // Load user + login state from GetStorage (sync)
    isLoggedIn.value = _storage.read('isLoggedIn') ?? false;

    final userJson = _storage.read('user');
    if (userJson != null) {
      currentUser.value =
          UserModel.fromJson(Map<String, dynamic>.from(userJson));
    }
  }

  void _initDio() {
    dio = Dio(BaseOptions(baseUrl: StringAssets.baseUrl));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Use current reactive token value
        final token = accessToken.value;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        if (error.response?.statusCode == 401 && refreshToken.value != null) {
          final success = await _refreshTokens();
          if (success) {
            final retry = error.requestOptions;
            retry.headers['Authorization'] = 'Bearer ${accessToken.value}';
            final response = await dio.fetch(retry);
            return handler.resolve(response);
          } else {
            await clearUser();
            Fluttertoast.showToast(
              msg: "Session expired. Please log in again.",
              backgroundColor: Colors.red,
            );
            return handler.reject(error);
          }
        }
        return handler.next(error);
      },
    ));
  }

  Future<void> skipLoginRegiser() async {
    await box.write('loginPromptedOnce', true);
    await box.write('registerPromptedOnce', true);
    loginPromptedOnce.value = true;
    registerPromptedOnce.value = true;
  }

  // Onboarding data
  final List<Map<String, dynamic>> onboardingData = [
    {
      'title': StringAssets.onboardingTitle1,
      'description': StringAssets.onboardingDesc1,
      'image': AppAssets.logo,
      'backgroundColor':
          AppColors.primary, // Using AppColors.surface (0xFFF8F5F0)
    },
    {
      'title': StringAssets.onboardingTitle2,
      'description': StringAssets.onboardingDesc2,
      'image': AppAssets.explore,
      'backgroundColor': AppColors.onSurface,
    },
    {
      'title': StringAssets.onboardingTitle3,
      'description': StringAssets.onboardingDesc3,
      'image': AppAssets.travelDiary,
      'backgroundColor': AppColors.background,
    },
  ];

  // Save user and tokens after login/register
  Future<void> setUser(UserModel user,
      {required String access, required String refresh}) async {
    currentUser.value = user;
    _storage.write('user', user.toJson());

    await _secureStorage.write(key: 'accessToken', value: access);
    await _secureStorage.write(key: 'refreshToken', value: refresh);
    accessToken.value = access;
    refreshToken.value = refresh;

    isLoggedIn.value = true;
    _storage.write('isLoggedIn', true);
  }

  // Clear user and tokens on logout or token expiry
  Future<void> clearUser() async {
    currentUser.value = null;
    _storage.remove('user');

    await _secureStorage.delete(key: 'accessToken');
    await _secureStorage.delete(key: 'refreshToken');
    accessToken.value = null;
    refreshToken.value = null;

    isLoggedIn.value = false;
    _storage.write('isLoggedIn', false);
  }

  Future<UserModel?> getUserProfile() async {
    if (accessToken.value == null || refreshToken.value == null) {
      Fluttertoast.showToast(
        msg: "No access or refresh token found!",
        backgroundColor: Colors.red,
      );
      return null;
    }
    try {
      final response = await dio.get('/v1/profile/');
      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data['data']);
        currentUser.value = user;
        Fluttertoast.showToast(msg: "Welcome back, ${user.fullName}!");
        return user;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error fetching profile.",
        backgroundColor: Colors.red,
      );
    }
    return null;
  }

  Future<bool> _refreshTokens() async {
    try {
      final response = await dio.post('v1/token/refresh/', data: {
        'refresh': refreshToken.value,
      });
      if (response.statusCode == 200) {
        final newAccess = response.data['access'];
        final newRefresh = response.data['refresh'] ?? refreshToken.value;

        await _secureStorage.write(key: 'accessToken', value: newAccess);
        await _secureStorage.write(key: 'refreshToken', value: newRefresh);
        accessToken.value = newAccess;
        refreshToken.value = newRefresh;

        return true;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to refresh token.",
        backgroundColor: Colors.red,
      );
    }
    return false;
  }

  Future<void> checkLogin() async {
    await Future.delayed(const Duration(milliseconds: 500)); // splash wait

    if (accessToken.value != null && refreshToken.value != null) {
      final refreshed = await _refreshTokens();
      if (refreshed) {
        await getUserProfile();
        isLoggedIn.value = true;
        Get.offAll(() => const NavigationPage());
        return;
      }
    }

    await clearUser();

    if (_storage.read('seenOnboarding') == true) {
      Get.offAll(() => const NavigationPage());
    } else {
      Get.offAll(() => const OnboardingScreen());
    }
  }

  List<Widget> get screens => [
        const HomeScreen(),
        const DiscoverScreen(),
        Obx(() {
          if (isLoggedIn.value) {
            if (Get.isRegistered<LoginController>(tag: ControllerIds.login)) {
              Get.delete<LoginController>(tag: ControllerIds.login);
            }
            if (!Get.isRegistered<ProfileController>(
                tag: ControllerIds.profile)) {
              Get.put(ProfileController(), tag: ControllerIds.profile);
            }
            return ProfileScreen(); // no const here
          } else {
            if (Get.isRegistered<ProfileController>(
                tag: ControllerIds.profile)) {
              Get.delete<ProfileController>(tag: ControllerIds.profile);
            }
            if (!Get.isRegistered<LoginController>(tag: ControllerIds.login)) {
              Get.put(LoginController(), tag: ControllerIds.login);
            }
            return LoginPage(); // no const here
          }
        }),
      ];

  Future<File?> pickImage({required bool isProfilePic}) async {
    try {
      final picker = ImagePicker();
      ImageSource source = await _showImageSourceDialog();

      final XFile? picked = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (picked == null) return null;

      final file = File(picked.path);
      final profileCtrl =
          Get.find<ProfileController>(tag: ControllerIds.profile);

      if (isProfilePic) {
        profileCtrl.tempProfilePic.value = file.path;
        profileCtrl.isUploadingProfilePic.value = true;
        await profileCtrl.updateUserInfo(profilePicPath: file.path);
      } else {
        profileCtrl.tempCoverPic.value = file.path;
        profileCtrl.isUploadingCoverPic.value = true;
        await profileCtrl.updateUserInfo(coverPicPath: file.path);
      }

      return file;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error picking image: $e');
      return null;
    }
  }

// Fixed bottom sheet to return ImageSource properly
  Future<ImageSource> _showImageSourceDialog() async {
    final completer = Completer<ImageSource>();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                completer.complete(ImageSource.camera);
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () {
                completer.complete(ImageSource.gallery);
                Get.back();
              },
            ),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );

    // Default to gallery if user closes sheet without selecting
    return completer.future;
  }
}
