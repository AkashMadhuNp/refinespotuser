import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add a salon to favorites
  Future<void> addToFavorites(Map<String, dynamic> salonData) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final salonId = salonData['salonId'] ?? salonData['uid'];
    if (salonId == null) {
      throw Exception('Salon ID is missing');
    }

    // Add timestamp if not present
    if (!salonData.containsKey('addedAt')) {
      salonData['addedAt'] = FieldValue.serverTimestamp();
    }

    // Add the salon to user favorites
    await _firestore
        .collection('favorites')
        .doc(user.uid)
        .collection('userFavorites')
        .doc(salonId)
        .set(salonData);
  }

  // Remove a salon from favorites
  Future<void> removeFromFavorites(String salonId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    if (salonId.isEmpty) {
      throw Exception('Salon ID is required');
    }
    
    print('Removing salon with ID $salonId from favorites');

    await _firestore
        .collection('favorites')
        .doc(user.uid)
        .collection('userFavorites')
        .doc(salonId)
        .delete();
  }

  // Check if a salon is in favorites
  Future<bool> isFavorite(String salonId) async {
    final user = _auth.currentUser;
    if (user == null) {
      return false;
    }

    final docSnapshot = await _firestore
        .collection('favorites')
        .doc(user.uid)
        .collection('userFavorites')
        .doc(salonId)
        .get();

    return docSnapshot.exists;
  }

  // Get all favorite salons
  Future<List<Map<String, dynamic>>> getAllFavorites() async {
    final user = _auth.currentUser;
    if (user == null) {
      return [];
    }

    final snapshot = await _firestore
        .collection('favorites')
        .doc(user.uid)
        .collection('userFavorites')
        .get();

    return snapshot.docs
        .map((doc) {
          final data = doc.data();
          // Ensure salonId is available
          data['salonId'] = doc.id;
          return data;
        })
        .toList();
  }
}