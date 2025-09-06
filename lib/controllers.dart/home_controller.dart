import 'dart:convert';
import 'package:frontend/constants/app_strings.dart';
import 'package:frontend/data/models/destination.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class HomeController extends GetxController {
  static HomeController get to => Get.find();

  var isLoading = false.obs;
  var isSearching = false.obs;

  var isLoadingMoreStart = false.obs;
  var isLoadingMoreEnd = false.obs;

  var allDestinations = <Destination>[].obs;
  var filteredPopularDestinations = <Destination>[].obs;

  var nextUrl = RxnString();
  var prevUrl = RxnString();

  final Dio _dio = Dio(BaseOptions(baseUrl: StringAssets.baseUrl));
  final _storage = GetStorage();
  static const _destinationsKey = "cached_destinations";

  var unreadNotificationsCount = 0.obs;

  // Keep track of IDs to prevent duplicates
  final _ids = <String>{};

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    // Load cached data first
    final cachedData = _storage.read(_destinationsKey);
    if (cachedData != null) {
      try {
        final List data = jsonDecode(cachedData);
        final cachedDestinations =
            data.map((json) => Destination.fromJson(json)).toList();
        allDestinations.value = cachedDestinations;
        _ids.addAll(cachedDestinations.map((e) => e.id));
      } catch (e) {
        print("Error reading cache: $e");
      }
    }

    // Fetch latest data from API
    await fetchDestinations();
  }

  /// Initial fetch (replace existing)
  Future<void> fetchDestinations({String? url}) async {
    try {
      isLoading.value = true;
      final response = await _dio.get(url ?? "v1/destinations/");
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        nextUrl.value = data['next'];
        prevUrl.value = data['previous'];

        final List results = data['results'];
        final destinations =
            results.map((json) => Destination.fromJson(json)).toList();

        allDestinations.value = destinations;
        _ids.clear();
        _ids.addAll(destinations.map((e) => e.id));

        _storage.write(_destinationsKey, jsonEncode(results));
      }
    } catch (e) {
      print("Error fetching destinations: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Append next page
  Future<void> loadNextPage() async {
    if (nextUrl.value == null) return;
    if (isLoadingMoreEnd.value) return;

    isLoadingMoreEnd.value = true;
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final response = await _dio.get(nextUrl.value!);
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        nextUrl.value = data['next'];
        prevUrl.value = data['previous'];

        final List results = data['results'];
        final newItems =
            results.map((json) => Destination.fromJson(json)).toList();

        // Append new items, prevent duplicates
        final filtered = newItems.where((d) => !_ids.contains(d.id)).toList();
        _ids.addAll(filtered.map((d) => d.id));
        allDestinations.addAll(filtered);

        // Update cache with full list
        _storage.write(_destinationsKey,
            jsonEncode(allDestinations.map((d) => d.toJson()).toList()));
      }
    } catch (e) {
      print("Error loading next page: $e");
    } finally {
      isLoadingMoreEnd.value = false;
    }
  }

  /// Prepend previous page
  Future<void> loadPreviousPage() async {
    if (prevUrl.value == null) return;
    if (isLoadingMoreStart.value) return;

    isLoadingMoreStart.value = true;
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final response = await _dio.get(prevUrl.value!);
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        nextUrl.value = data['next'];
        prevUrl.value = data['previous'];

        final List results = data['results'];
        final newItems =
            results.map((json) => Destination.fromJson(json)).toList();

        // Prepend new items, prevent duplicates
        final filtered = newItems.where((d) => !_ids.contains(d.id)).toList();
        _ids.addAll(filtered.map((d) => d.id));
        allDestinations.insertAll(0, filtered);

        // Update cache with full list
        _storage.write(_destinationsKey,
            jsonEncode(allDestinations.map((d) => d.toJson()).toList()));
      }
    } catch (e) {
      print("Error loading previous page: $e");
    } finally {
      isLoadingMoreStart.value = false;
    }
  }

  void toggleFavorite(Destination destination) {
    destination.isFavorite.value = !destination.isFavorite.value;
    allDestinations.refresh();
  }

  void search(String query) {
    isSearching.value = true;
    if (query.isEmpty) {
      filteredPopularDestinations.value = allDestinations;
    } else {
      filteredPopularDestinations.value = allDestinations
          .where((d) => d.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    isSearching.value = false;
  }
}
