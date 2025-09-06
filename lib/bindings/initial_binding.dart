import 'package:frontend/controllers.dart/destination_detail_screen_controller.dart';
import 'package:frontend/controllers.dart/discover_controller.dart';
import 'package:frontend/controllers.dart/forgot_password_controller.dart';
import 'package:frontend/controllers.dart/global_controller.dart';
import 'package:frontend/controllers.dart/home_controller.dart';
import 'package:frontend/controllers.dart/login_controller.dart';
import 'package:frontend/controllers.dart/profile_controller.dart';
import 'package:frontend/controllers.dart/register_controller.dart';
import 'package:get/get.dart';
import 'controller_ids.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(GlobalController(), tag: ControllerIds.global, permanent: true);
    Get.lazyPut(() => LoginController(), tag: ControllerIds.login, fenix: true);
    Get.lazyPut(() => RegisterController(),
        tag: ControllerIds.register, fenix: true);

    Get.lazyPut(() => ProfileController(),
        tag: ControllerIds.profile, fenix: true);

    Get.lazyPut(() => HomeController(), tag: ControllerIds.home, fenix: true);
    Get.lazyPut(() => DiscoverController(),
        tag: ControllerIds.discover, fenix: true);

    Get.lazyPut(() => DestinationDetailScreenController(),
        tag: ControllerIds.destinationDetailScreen, fenix: true);

    Get.lazyPut(() => ForgotPasswordController(),
        tag: ControllerIds.forgotPassword, fenix: true);
  }
}
