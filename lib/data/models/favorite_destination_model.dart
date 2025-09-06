class FavoriteDestinationModel {
  final String userId;
  final String destinationId;
  final DateTime addedAt;

  FavoriteDestinationModel({
    required this.userId,
    required this.destinationId,
    required this.addedAt,
  });

  factory FavoriteDestinationModel.fromJson(Map<String, dynamic> json) {
    return FavoriteDestinationModel(
      userId: json['userId'] ?? '',
      destinationId: json['destinationId'] ?? '',
      addedAt: DateTime.tryParse(json['addedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'destinationId': destinationId,
      'addedAt': addedAt.toIso8601String(),
    };
  }
}
