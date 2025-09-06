import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/bindings/controller_ids.dart';
import 'package:frontend/controllers.dart/global_controller.dart';
import 'package:get/get.dart';

/// A service to monitor internet connectivity and notify user when disconnected.
class InternetProvider {
  // Singleton pattern
  static final InternetProvider _instance = InternetProvider._internal();
  factory InternetProvider() => _instance;
  InternetProvider._internal();

  final globalController =
      Get.find<GlobalController>(tag: ControllerIds.global);

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Starts monitoring the internet connection.
  void startMonitoring() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      // In version >=5.0.0, results is List<ConnectivityResult>
      final hasConnection = results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi);

      // Update global state
      globalController.isConnected.value = hasConnection;

      // Show snackbar only when disconnected
      if (!hasConnection) {
        final errorColor = Get.theme.colorScheme.error;
        Fluttertoast.showToast(
          msg: "No internet connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: errorColor,
          textColor: Colors.white,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Connected to the internet",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          textColor: Colors.green,
        );
      }
    });
  }

  /// Determine if current connectivity result indicates a valid internet connection.
  bool isConnected(ConnectivityResult result) {
    return result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi;
  }

  /// Dispose the subscription when not needed.
  void dispose() {
    _subscription?.cancel();
  }
}
