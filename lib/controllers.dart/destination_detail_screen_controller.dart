import 'package:get/get.dart';

class DestinationDetailScreenController extends GetxController {
  static DestinationDetailScreenController get to => Get.find();

  RxList<bool> isExpandedList = [false, false, false, false].obs;

  void togglePanel(int index) {
    isExpandedList[index] = !isExpandedList[index];
  }
}
