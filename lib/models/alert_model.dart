class AlertModel {
  final String id;
  final String alertType; // 'Emergency' or 'Warning'
  final bool isActive;
  final String location;
  final double latitude;
  final double longitude;
  final DateTime dateTime;
  final String details;
  final String imageUrl;

  AlertModel({
    required this.id,
    required this.alertType,
    required this.isActive,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.dateTime,
    required this.details,
    required this.imageUrl,
  });

  // Create AlertModel from Firebase Realtime Database snapshot
  factory AlertModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return AlertModel(
      id: id,
      alertType: map['alertType'] ?? 'Warning',
      isActive: map['isActive'] ?? false,
      location: map['location'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      dateTime: map['dateTime'] != null
          ? DateTime.parse(map['dateTime'])
          : DateTime.now(),
      details: map['details'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  // Convert AlertModel to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'alertType': alertType,
      'isActive': isActive,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'dateTime': dateTime.toIso8601String(),
      'details': details,
      'imageUrl': imageUrl,
    };
  }

  // Copy with method for updating fields
  AlertModel copyWith({
    String? id,
    String? alertType,
    bool? isActive,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? dateTime,
    String? details,
    String? imageUrl,
  }) {
    return AlertModel(
      id: id ?? this.id,
      alertType: alertType ?? this.alertType,
      isActive: isActive ?? this.isActive,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      dateTime: dateTime ?? this.dateTime,
      details: details ?? this.details,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
