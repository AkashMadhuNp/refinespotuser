import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteSalon {
  final String salonId;
  final String salonName;
  final String name;
  final String location;
  final String profileUrl;
  final DateTime addedAt;

  FavoriteSalon({
    required this.salonId,
    required this.salonName,
    required this.name,
    required this.location,
    required this.profileUrl,
    required this.addedAt,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'salonId': salonId,
      'salonName': salonName,
      'name': name,
      'location': location,
      'profileUrl': profileUrl,
      'addedAt': addedAt,
    };
  }

  // Create from Firebase Map
  factory FavoriteSalon.fromMap(Map<String, dynamic> map) {
    return FavoriteSalon(
      salonId: map['salonId'],
      salonName: map['salonName'],
      name: map['name'],
      location: map['location'],
      profileUrl: map['profileUrl'],
      addedAt: (map['addedAt'] as Timestamp).toDate(),
    );
  }
}
