import 'package:frontend/constants/app_strings.dart';
import 'package:get/get.dart';

/// ✅ Wrapper for paginated response
class DestinationResponse {
  final String? next;
  final String? previous;
  final List<Destination> results;

  DestinationResponse({
    required this.next,
    required this.previous,
    required this.results,
  });

  factory DestinationResponse.fromJson(Map<String, dynamic> json) {
    return DestinationResponse(
      next: json['next']?.toString(),
      previous: json['previous']?.toString(),
      results: (json['results'] as List<dynamic>)
          .map((e) => Destination.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "next": next,
      "previous": previous,
      "results": results.map((e) => e.toJson()).toList(),
    };
  }
}

/// ✅ Destination model
class Destination {
  final String id;
  final String name;
  final String description;
  final String location;
  final String mainImage; // relative path or URL
  final double latitude;
  final double longitude;
  final List<String> tags;
  final List<GalleryImage> gallery;
  final String bestTimeToVisit;
  final String estimatedCost;
  final String estimatedDuration;
  final String history;
  final String howToReach;
  final double rating;
  final int ratingCount;
  final String category;
  final bool isPopular;
  final RxBool isFavorite;
  final String createdAt;
  final List<Equipment> equipments;
  final List<Itinerary> itineraries;

  Destination({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.mainImage,
    required this.latitude,
    required this.longitude,
    required this.tags,
    required this.gallery,
    required this.bestTimeToVisit,
    required this.estimatedCost,
    required this.estimatedDuration,
    required this.history,
    required this.howToReach,
    required this.rating,
    required this.ratingCount,
    required this.category,
    required this.isPopular,
    bool isFavorite = false,
    required this.createdAt,
    required this.equipments,
    required this.itineraries,
  }) : isFavorite = RxBool(isFavorite);

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      mainImage: json['main_image']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      tags: List<String>.from(json['tags'] ?? []),
      gallery: (json['gallery_images'] as List<dynamic>? ?? [])
          .map((g) => GalleryImage.fromJson(g))
          .toList(),
      bestTimeToVisit: json['best_time_to_visit']?.toString() ?? '',
      estimatedCost: json['estimated_cost']?.toString() ?? '',
      estimatedDuration: json['estimated_duration']?.toString() ?? '',
      history: json['history']?.toString() ?? '',
      howToReach: json['how_to_reach']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (json['rating_count'] as num?)?.toInt() ?? 0,
      category: json['category']?.toString() ?? 'general',
      isPopular: json['is_popular'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
      createdAt: json['created_at']?.toString() ?? '',
      equipments: (json['equipments'] as List<dynamic>? ?? [])
          .map((e) => Equipment.fromJson(e))
          .toList(),
      itineraries: (json['itineraries'] as List<dynamic>? ?? [])
          .map((i) => Itinerary.fromJson(i))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "location": location,
      "main_image": mainImage,
      "latitude": latitude,
      "longitude": longitude,
      "tags": tags,
      "gallery_images": gallery.map((g) => g.toJson()).toList(),
      "best_time_to_visit": bestTimeToVisit,
      "estimated_cost": estimatedCost,
      "estimated_duration": estimatedDuration,
      "history": history,
      "how_to_reach": howToReach,
      "rating": rating,
      "rating_count": ratingCount,
      "category": category,
      "is_popular": isPopular,
      "isFavorite": isFavorite.value,
      "created_at": createdAt,
      "equipments": equipments.map((e) => e.toJson()).toList(),
      "itineraries": itineraries.map((i) => i.toJson()).toList(),
    };
  }

  /// ✅ Full URL for main image
  String? get mainImageUrl {
    if (mainImage.isEmpty) return null;
    if (mainImage.startsWith('http')) return mainImage;
    return StringAssets.mediaUrl + mainImage;
  }

  /// ✅ Full URLs for gallery images
  List<String> get galleryUrls {
    return gallery.map((g) {
      if (g.image.isEmpty) return '';
      if (g.image.startsWith('http')) return g.image;
      return StringAssets.mediaUrl + g.image;
    }).toList();
  }
}

/// ✅ Gallery image model
class GalleryImage {
  final String id;
  final String image;
  final String caption;

  GalleryImage({
    required this.id,
    required this.image,
    required this.caption,
  });

  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    return GalleryImage(
      id: json['id']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      caption: json['caption']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "image": image,
      "caption": caption,
    };
  }
}

/// ✅ Equipment model
class Equipment {
  final String id;
  final String name;
  final String importance;

  Equipment({
    required this.id,
    required this.name,
    required this.importance,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      importance: json['importance'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "importance": importance,
    };
  }
}

/// ✅ Itinerary model
class Itinerary {
  final String id;
  final int day;
  final String title;
  final String description;

  Itinerary({
    required this.id,
    required this.day,
    required this.title,
    required this.description,
  });

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
      id: json['id'].toString(),
      day: json['day'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "day": day,
      "title": title,
      "description": description,
    };
  }
}
