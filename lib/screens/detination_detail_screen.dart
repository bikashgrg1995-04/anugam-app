import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:frontend/bindings/controller_ids.dart';
import 'package:frontend/controllers.dart/destination_detail_screen_controller.dart';
import 'package:frontend/data/models/destination.dart';
import 'package:frontend/widgets/destination_gallery.dart';
import 'package:get/get.dart';

class DestinationDetailScreen extends StatefulWidget {
  const DestinationDetailScreen({super.key});

  @override
  State<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  final destinationDetailScreenController = Get.put(
    DestinationDetailScreenController(),
    tag: ControllerIds.destinationDetailScreen,
  );

  late Destination destination;
  bool isSaved = false;

  GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    destination = args?['destination'] as Destination;
    isSaved = destination.isFavorite.value;
  }

  @override
  Widget build(BuildContext context) {
    final LatLng destinationLatLng = LatLng(
        destination.latitude, destination.longitude); // Default Kathmandu

    return Scaffold(
      appBar: AppBar(
        title: Text(destination.name),
        actions: [
          Obx(() => IconButton(
                highlightColor: Colors.red.withOpacity(0.2),
                icon: Icon(
                  destination.isFavorite.value
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color:
                      destination.isFavorite.value ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  destination.isFavorite.toggle();
                  Get.snackbar(
                    destination.isFavorite.value ? 'Saved' : 'Removed',
                    destination.isFavorite.value
                        ? 'Added to your favorites'
                        : 'Removed from favorites',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              )),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🖼️ Destination gallery Image
                if (destination.mainImageUrl != null)
                  DestinationGallery(imageUrls: destination.galleryUrls)
                else
                  Container(
                    height: 220,
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child:
                        const Icon(Icons.image, size: 50, color: Colors.grey),
                  ),

                const SizedBox(height: 16),

                // 📍 Destination Name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    destination.name,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 16),

                // 📖 Overview
                _buildSection(
                    title: "Overview", content: destination.description),

                // 🚍 Transport
                _buildSection(
                    title: "Transport", content: destination.howToReach),

                // 🌤️ Best Season
                _buildSection(
                    title: "Best Season", content: destination.bestTimeToVisit),

                // 📜 Expandable Details
                Obx(() => ExpansionPanelList(
                      expansionCallback: (index, isExpanded) {
                        destinationDetailScreenController.togglePanel(index);
                      },
                      expandedHeaderPadding: EdgeInsets.zero,
                      children: [
                        // 🔹 Expansion Panels for history
                        _buildExpansionPanel(
                            index: 0,
                            title: "History",
                            content: destination.history),

                        // 🔹 Expansion Panels for checklist
                        _buildExpansionPanel(
                            index: 1,
                            title: "Checklist",
                            content: destination.equipments
                                .map((e) => e.name)
                                .join(', ')),

                        // 🔹 Expansion Panels for cost estimates
                        _buildExpansionPanel(
                            index: 2,
                            title: "Cost Estimates",
                            content: destination.estimatedCost),

                        // 🔹 Expansion Panels for itinerary
                        // 🔹 Expansion Panels for itinerary
                        _buildExpansionPanel(
                          index: 3,
                          title: "Suggested Itinerary",
                          contentWidget: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: destination.itineraries
                                .asMap()
                                .entries
                                .map((entry) {
                              final dayIndex = entry.key + 1;
                              final itinerary = entry.value;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 🗓️ Day + Title
                                    Text(
                                      "Day $dayIndex: ${itinerary.title}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // 📝 Description
                                    Text(
                                      itinerary.description,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    )),

                const SizedBox(height: 16),

                // 🗺️ Map
                Container(
                  height: 220,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: destinationLatLng,
                        zoom: 12,
                      ),
                      onMapCreated: (controller) => mapController = controller,
                      markers: {
                        Marker(
                          markerId: MarkerId(destination.name),
                          position: destinationLatLng,
                          infoWindow: InfoWindow(title: destination.name),
                        ),
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 120),
              ],
            ),
          ),

          // 🔘 Bottom Buttons
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Get.snackbar(
                        "Cost Calculator", "Launching cost calculator...",
                        snackPosition: SnackPosition.BOTTOM);
                  },
                  icon: const Icon(Icons.calculate),
                  label: const Text("Cost Calculator"),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.snackbar(
                        "Create Itinerary", "Launching itinerary builder...",
                        snackPosition: SnackPosition.BOTTOM);
                  },
                  icon: const Icon(Icons.list_alt),
                  label: const Text("Create Itinerary"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Section Widget
  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Text(content, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  // 🔹 Expansion Panel
  ExpansionPanel _buildExpansionPanel({
    required int index,
    required String title,
    String? content,
    Widget? contentWidget,
  }) {
    return ExpansionPanel(
      isExpanded: destinationDetailScreenController.isExpandedList[index],
      headerBuilder: (_, __) => ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Align(
          alignment: Alignment.topLeft,
          child: contentWidget ??
              Text(
                content ?? "",
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
        ),
      ),
    );
  }
}
