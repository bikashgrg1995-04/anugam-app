class TravelDiaryEntryModel {
  final String id;
  final String userId;
  final String destinationId;
  final String title;
  final String content;
  final List<String>? photos;
  final DateTime createdAt;

  TravelDiaryEntryModel({
    required this.id,
    required this.userId,
    required this.destinationId,
    required this.title,
    required this.content,
    this.photos,
    required this.createdAt,
  });

  factory TravelDiaryEntryModel.fromJson(Map<String, dynamic> json) {
    return TravelDiaryEntryModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      destinationId: json['destinationId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      photos: (json['photos'] as List?)?.map((e) => e.toString()).toList(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'destinationId': destinationId,
      'title': title,
      'content': content,
      'photos': photos,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
