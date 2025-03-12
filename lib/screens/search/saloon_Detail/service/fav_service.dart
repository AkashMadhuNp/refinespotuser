import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<bool> checkFavoriteStatus(String? salonId) {
    final user = _auth.currentUser;
    
    if (user == null || salonId == null) {
      return Stream.value(false);
    }

    return _firestore
        .collection('favorites')
        .where('userId', isEqualTo: user.uid)
        .where('salonId', isEqualTo: salonId)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  Future<bool> toggleFavorite(Map<String, dynamic> salonData, String? salonId) async {
    final user = _auth.currentUser;

    if (user == null || salonId == null) {
      return false;
    }

    try {
      final userFavoritesRef = _firestore
          .collection('favorites')
          .doc(user.uid)
          .collection('userFavorites')
          .doc(salonId);
          
      final docSnapshot = await userFavoritesRef.get();
      
      if (docSnapshot.exists) {
        await userFavoritesRef.delete();
        return false;
      } else {
        await userFavoritesRef.set({
          'salonId': salonId,
          'timestamp': FieldValue.serverTimestamp(),
          'salonName': salonData['saloonName'] ?? salonData['name'],
          'shopUrl': salonData['shopUrl'],
          'services': salonData['services'],
          'workingHours': salonData['workingHours'],
        });
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  static String? getSalonId(Map<String, dynamic> salonData) {
    return salonData['uid']?.toString() ?? 
           salonData['id']?.toString() ?? 
           salonData['salonId']?.toString();
  }
}