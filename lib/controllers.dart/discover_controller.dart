import 'package:flutter/material.dart';
import 'package:frontend/bindings/controller_ids.dart';
import 'package:frontend/controllers.dart/home_controller.dart';
import 'package:get/get.dart';
import '../data/models/destination.dart';

class DiscoverController extends GetxController {
  static DiscoverController get to => Get.find();

  final TextEditingController searchController = TextEditingController();

  RxList<Destination> allDestinations = <Destination>[].obs;
  RxList<Destination> filteredDestinations = <Destination>[].obs;
  RxBool isLoading = false.obs;
  RxBool isSearching = false.obs;
  RxString selectedFilter = "All".obs;

  final homeController = Get.find<HomeController>(tag: ControllerIds.home);

  @override
  void onInit() {
    super.onInit();
    loadDestinations();
  }

  void loadDestinations() {
    isLoading.value = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      allDestinations.value = homeController.allDestinations;
      isLoading.value = false;
    });
  }

  // void search(String query) {
  //   isSearching.value = true;
  //   Future.delayed(Duration(milliseconds: 300), () {
  //     if (query.trim().isEmpty) {
  //       filteredDestinations.value = homeController.allDestinations;
  //     } else {
  //       filteredDestinations.value = homeController.allDestinations
  //           .where((d) => d.name.toLowerCase().contains(query.toLowerCase()))
  //           .toList();
  //     }
  //     isSearching.value = false;
  //   });
  // }

  void search(String query) {
    isSearching.value = true;
    if (query.isEmpty) {
      filteredDestinations.value = allDestinations;
    } else {
      filteredDestinations.value = allDestinations
          .where((d) => d.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    isSearching.value = false;
  }

  void applyFilter(String filter) {
    selectedFilter.value = filter;

    if (filter == "All") {
      filteredDestinations.value = homeController.allDestinations;
    } else {
      filteredDestinations.value = homeController.allDestinations
          .where((d) => d.name.toLowerCase().contains(filter.toLowerCase()))
          .toList();
    }
  }
}
