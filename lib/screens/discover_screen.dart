import 'package:flutter/material.dart';
import 'package:frontend/bindings/controller_ids.dart';
import 'package:frontend/controllers.dart/discover_controller.dart';
import 'package:frontend/controllers.dart/global_controller.dart';
import 'package:frontend/controllers.dart/home_controller.dart';
import 'package:frontend/screens/suggest_destinations.dart';
import 'package:frontend/widgets/common_widgets.dart';
import 'package:get/get.dart';
import 'package:frontend/utils/extensions.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final discoverController =
      Get.put(DiscoverController(), tag: ControllerIds.discover);
  final homeController = Get.put(HomeController(), tag: ControllerIds.home);
  final globalController =
      Get.put(GlobalController(), tag: ControllerIds.global);

  final ScrollController _scrollController = ScrollController();
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    // Initialize the search controller
    _searchController = TextEditingController();

    // Load destinations if not already loaded
    if (homeController.allDestinations.isEmpty) {
      homeController.loadData();
    }

    // Setup pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !homeController.isLoadingMoreEnd.value) {
        homeController.loadNextPage();
      }
    });
  }

  void onSearchChanged(String query) {
    discoverController.search(query);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        floatingActionButton: globalController.isLoggedIn.value
            ? FloatingActionButton(
                onPressed: () => Get.dialog(const SuggestDestinationDialog()),
                child: const Icon(Icons.add_location_alt),
              )
            : null,
        body: Padding(
          padding: EdgeInsets.all(0.04.sw(context)),
          child: Column(
            children: [
              // Search bar

              searchBarWidget(
                context: context,
                controller: _searchController,
                onChanged: onSearchChanged,
                onPressed: () =>
                    discoverController.search(_searchController.text),
              ),
              SizedBox(height: 0.02.sh(context)),

              // Filter chips
              SizedBox(
                height: 0.045.sh(context),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: ["All", "Nearby", "Hiking", "Low Budget", "Winter"]
                      .length,
                  separatorBuilder: (_, __) => SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = [
                      "All",
                      "Nearby",
                      "Hiking",
                      "Low Budget",
                      "Winter"
                    ][index];
                    return ChoiceChip(
                      elevation: 0,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.symmetric(
                          horizontal: 0.03.sw(context),
                          vertical: 0.005.sh(context)),
                      label: Text(
                        filter,
                        style: TextStyle(fontSize: 0.012.toRes(context)),
                      ),
                      selected:
                          discoverController.selectedFilter.value == filter,
                      onSelected: (_) => discoverController.applyFilter(filter),
                    );
                  },
                ),
              ),

              SizedBox(height: 0.02.sh(context)),

              // Destinations list with pagination
              Expanded(
                child: Obx(() {
                  final destinations = discoverController.filteredDestinations;

                  if (homeController.isLoading.value) {
                    return ListView.separated(
                      itemCount: 4,
                      separatorBuilder: (_, __) =>
                          SizedBox(height: 0.02.sh(context)),
                      itemBuilder: (_, __) => shimmerCard(context, count: 4),
                    );
                  }

                  if (destinations.isEmpty) {
                    return Center(
                      child: Text(
                        "No destinations found",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.separated(
                    controller: _scrollController,
                    itemCount: destinations.length + 1, // +1 for loader
                    separatorBuilder: (_, __) =>
                        SizedBox(height: 0.02.sh(context)),
                    itemBuilder: (context, index) {
                      if (index == destinations.length) {
                        // Show loader at bottom when fetching next page
                        return Obx(() => homeController.isLoadingMoreEnd.value
                            ? Center(child: CircularProgressIndicator())
                            : SizedBox.shrink());
                      }

                      final place = destinations[index];
                      return GestureDetector(
                        onTap: () {
                          // Navigate to detail screen
                        },
                        child: destinationCard(context, place),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
