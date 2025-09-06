import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/bindings/controller_ids.dart';
import 'package:frontend/constants/app_strings.dart';
import 'package:frontend/controllers.dart/global_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';

class DioService {
  static final Dio _dio = Dio();
  static final _storage = const FlutterSecureStorage();

  // Initialize Dio with base URL and default options
  static Dio get dio {
    _dio.options.baseUrl = StringAssets.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers['Content-Type'] = 'application/json';

    _dio.interceptors.clear();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await _storage.read(key: 'access');
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
        onError: (e, handler) async {
          if (e.response?.statusCode == 401) {
            // only token refresh / logout handled here
            await _handleUnauthorized(e, handler);
            return;
          }
          return handler.next(e); // pass other errors to feature functions
        },
      ),
    );

    return _dio;
  }

// Handle unauthorized access by refreshing token or logging out
  static Future<void> _handleUnauthorized(
      DioException e, ErrorInterceptorHandler handler) async {
    Fluttertoast.showToast(msg: 'Access token is invalid or expired');

    final refreshToken = await _storage.read(key: 'refresh');
    if (refreshToken == null || refreshToken.isEmpty) {
      await _forceLogout();
      return handler.reject(e);
    }

    try {
      final refreshResponse = await Dio().post(
        '${StringAssets.baseUrl}v1/token/refresh/',
        data: {'refresh': refreshToken},
      );

      if (refreshResponse.statusCode == 200 &&
          refreshResponse.data['access'] != null) {
        final newAccess = refreshResponse.data['access'];
        await _storage.write(key: 'access', value: newAccess);

        final opts = e.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newAccess';

        final cloneReq = await _dio.fetch(opts);
        return handler.resolve(cloneReq);
      } else {
        await _forceLogout();
      }
    } catch (_) {
      await _forceLogout();
    }

    return handler.reject(e);
  }

// Force logout and clear all stored data
  static Future<void> _forceLogout() async {
    await _storage.deleteAll();

    final globalController =
        Get.find<GlobalController>(tag: ControllerIds.global);
    globalController.currentUser.value = null;
    globalController.isLoggedIn.value = false;

    Get.offAllNamed(AppRoutes.navigation, arguments: {'initialIndex': 2});
  }
}
