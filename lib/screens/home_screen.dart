import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/bindings/controller_ids.dart';
import 'package:frontend/controllers.dart/home_controller.dart';
import 'package:frontend/utils/extensions.dart';
import 'package:frontend/widgets/common_widgets.dart';
import 'package:get/get.dart';
import '../controllers.dart/global_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final globalController =
      Get.find<GlobalController>(tag: ControllerIds.global);
  final homeController = Get.put(HomeController(), tag: ControllerIds.home);

  late TextEditingController _searchController;
  late ScrollController _horizontalController; // for horizontal list

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _horizontalController = ScrollController();

    _horizontalController.addListener(_horizontalScrollListener);
  }

  void _horizontalScrollListener() {
    if (_horizontalController.position.pixels >=
        _horizontalController.position.maxScrollExtent - 50) {
      if (homeController.nextUrl.value != null &&
          !homeController.isLoading.value) {
        homeController.loadNextPage();
      }
    }
    if (_horizontalController.position.pixels <= 50) {
      if (homeController.prevUrl.value != null &&
          !homeController.isLoading.value) {
        homeController.loadPreviousPage();
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _horizontalController.removeListener(_horizontalScrollListener);
    _horizontalController.dispose();
    super.dispose();
  }

  void onSearchChanged(String query) {
    homeController.search(query);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 0.05.sw(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 0.02.sh(context)),
                welcomeHeader(globalController, context),
                SizedBox(height: 0.02.sh(context)),
                searchBarWidget(
                  context: context,
                  controller: _searchController,
                  onChanged: onSearchChanged,
                  onPressed: () =>
                      homeController.search(_searchController.text),
                ),
                SizedBox(height: 0.02.sh(context)),
                sectionHeader(title: "Popular Destinations", context: context),
                SizedBox(height: 0.02.sh(context)),

                /// Horizontal destination list with smooth animation
                Obx(() {
                  final destinations = _searchController.text.isEmpty
                      ? homeController.allDestinations
                      : homeController.filteredPopularDestinations;

                  if (homeController.isSearching.value ||
                      (homeController.isLoading.value &&
                          destinations.isEmpty)) {
                    return shimmerCard(context, count: 5);
                  } else if (destinations.isEmpty) {
                    return SizedBox(
                      height: 0.22.sh(context),
                      child: Center(
                        child: Text(
                          "No results found",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    );
                  } else {
                    return KeyedSubtree(
                      key: ValueKey(destinations.length), // track changes
                      child: horizontalDestinationList(
                        context: context,
                        items: destinations,
                        scrollController: _horizontalController,
                        onToggleFavorite: homeController.toggleFavorite,
                        isLoading: homeController.isLoading.value,
                      ),
                    );
                  }
                }),

                SizedBox(height: 0.03.sh(context)),
                nearbyPlacesCTA(context, onStart: () {
                  Fluttertoast.showToast(msg: "Coming Soon");
                }),
                SizedBox(height: 0.03.sh(context)),
                quickActions(context: context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget nearbyPlacesCTA(BuildContext context, {VoidCallback? onStart}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(0.02.toRes(context)),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      gradient: const LinearGradient(
        colors: [Colors.greenAccent, Colors.teal],
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Discover Nearby Places 🗺️",
          style: TextStyle(
              color: Colors.white,
              fontSize: 0.014.toRes(context),
              fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 0.005.sh(context)),
        Text(
          "Find attractions, restaurants, and hidden gems within 10 km of your location.",
          style:
              TextStyle(color: Colors.white70, fontSize: 0.012.toRes(context)),
        ),
        SizedBox(height: 0.012.sh(context)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.teal,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.012.toRes(context))),
          ),
          onPressed: onStart,
          child: const Text("Find Nearby Places"),
        )
      ],
    ),
  );
}
