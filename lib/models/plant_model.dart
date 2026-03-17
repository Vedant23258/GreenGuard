class PlantModel {
  final String plantId;
  final String plantName;
  final double latitude;
  final double longitude;
  final String photoUrl;
  final String status;
  final DateTime lastUpdated;

  const PlantModel({
    required this.plantId,
    required this.plantName,
    required this.latitude,
    required this.longitude,
    required this.photoUrl,
    required this.status,
    required this.lastUpdated,
  });

  PlantModel copyWith({
    String? plantId,
    String? plantName,
    double? latitude,
    double? longitude,
    String? photoUrl,
    String? status,
    DateTime? lastUpdated,
  }) {
    return PlantModel(
      plantId: plantId ?? this.plantId,
      plantName: plantName ?? this.plantName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plantId': plantId,
      'plantName': plantName,
      'latitude': latitude,
      'longitude': longitude,
      'photoUrl': photoUrl,
      'status': status,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory PlantModel.fromMap(Map<String, dynamic> map) {
    return PlantModel(
      plantId: (map['plantId'] ?? '').toString(),
      plantName: (map['plantName'] ?? '').toString(),
      latitude: (map['latitude'] is num)
          ? (map['latitude'] as num).toDouble()
          : double.tryParse((map['latitude'] ?? '0').toString()) ?? 0,
      longitude: (map['longitude'] is num)
          ? (map['longitude'] as num).toDouble()
          : double.tryParse((map['longitude'] ?? '0').toString()) ?? 0,
      photoUrl: (map['photoUrl'] ?? '').toString(),
      status: (map['status'] ?? '').toString(),
      lastUpdated: DateTime.tryParse((map['lastUpdated'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}

