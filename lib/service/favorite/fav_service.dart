import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sec_pro/models/favorite_model.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static const int _maxFavorites = 20; // Set your desired limit

  // Check if a salon is in favorites
  Stream<bool> isSalonFavorite(String salonId) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(false);

    return _firestore
        .collection('favorites')
        .doc(userId)
        .collection('userFavorites')
        .doc(salonId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  // Check if user can add more favorites
  Future<bool> canAddMoreFavorites() async {
  final userId = _auth.currentUser?.uid;
  if (userId == null) return false;

  final snapshot = await _firestore
      .collection('favorites')
      .doc(userId)
      .collection('userFavorites')
      .count()
      .get();

  final int favoritesCount = snapshot.count ?? 0; // Ensure it's not null
  return favoritesCount < _maxFavorites;
}


  // Add salon to favorites
  Future<void> addToFavorites(Map<String, dynamic> salonData) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final salonId = salonData['uid'] ?? salonData['salonId'];
    if (salonId == null) {
      throw Exception('Invalid salon ID');
    }

    // Check if already in favorites
    final docRef = _firestore
        .collection('favorites')
        .doc(userId)
        .collection('userFavorites')
        .doc(salonId);

    final doc = await docRef.get();
    if (doc.exists) {
      throw Exception('Salon already in favorites');
    }

    await docRef.set({
      'salonId': salonId,
      'salonName': salonData['saloonName'] ?? salonData['name'] ?? '',
      'name': salonData['name'] ?? '',
      'location': salonData['location'] ?? '',
      'profileUrl': salonData['shopUrl'] ?? salonData['profileUrl'] ?? '',
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // Remove from favorites
  Future<void> removeFromFavorites(String salonId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _firestore
        .collection('favorites')
        .doc(userId)
        .collection('userFavorites')
        .doc(salonId)
        .delete();
  }

  // Get user's favorites
  Stream<List<FavoriteSalon>> getFavorites() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('favorites')
        .doc(userId)
        .collection('userFavorites')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FavoriteSalon.fromMap({...doc.data(), 'salonId': doc.id}))
            .toList());
  }
}