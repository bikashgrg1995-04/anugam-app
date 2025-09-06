// lib/utils/app_globals.dart
import 'package:get/get.dart';
import 'package:frontend/controllers.dart/global_controller.dart';
import 'package:frontend/bindings/controller_ids.dart';

class AppGlobals {
  static GlobalController get global =>
      Get.find<GlobalController>(tag: ControllerIds.global);
}
