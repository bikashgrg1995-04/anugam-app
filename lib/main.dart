import 'package:flutter/material.dart';
import 'package:frontend/controllers.dart/global_controller.dart';
import 'package:frontend/data/providers/internet_provider.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init(); // Initialize storage

  // Put GlobalController
  Get.put(GlobalController(), tag: "globalController");

  // Start monitoring internet
  InternetProvider().startMonitoring();
  runApp(const AnugamApp());
}
