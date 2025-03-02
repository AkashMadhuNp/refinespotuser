import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserInfo {
  final String name;
  final String phone;

  UserInfo({required this.name, required this.phone});
}

class ReviewUtils {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetches the current user's information from Firestore
  static Future<UserInfo?> fetchUserInfo() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();
        
        if (userDoc.exists) {
          return UserInfo(
            name: userDoc.data()?['name'] ?? 'Anonymous',
            phone: userDoc.data()?['phone'] ?? '',
          );
        }
      }
      return null;
    } catch (e) {
      print('Error fetching user info: $e');
      rethrow;
    }
  }

  /// Submits a review and updates the salon's rating
  static Future<void> submitReview({
    required BuildContext context,
    required Map<String, dynamic> appointment,
    required double rating,
    required String reviewText,
    required String username,
    required String userPhone,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      final reviewData = {
        'userName': username,
        'userPhone': userPhone,
        'salonName': appointment['salonName'] ?? 'Unknown Salon',
        'salonId': appointment['salonId'] ?? '',
        'rating': rating,
        'review': reviewText,
        'createdAt': FieldValue.serverTimestamp(),
        'appointmentId': appointment['appointmentId'] ?? '',
        'date': appointment['date'] ?? '',
        'time': appointment['time'] ?? '',
        'userId': currentUser?.uid, // Store the user's UID
      };

      await _firestore.collection('review').add(reviewData);

      // Update salon rating if salonId exists
      if (appointment['salonId'] != null) {
        await _updateSalonRating(appointment['salonId'], rating);
      }
    } catch (e) {
      print('Error submitting review: $e');
      rethrow;
    }
  }

  /// Updates the salon's average rating in Firestore
  static Future<void> _updateSalonRating(String salonId, double newRating) async {
    final salonRef = _firestore
        .collection('approved_saloon')
        .doc(salonId);

    await _firestore.runTransaction((transaction) async {
      final salonDoc = await transaction.get(salonRef);
      
      if (salonDoc.exists) {
        final currentRating = salonDoc.data()?['rating'] ?? 0.0;
        final reviewCount = salonDoc.data()?['reviewCount'] ?? 0;
        
        final newReviewCount = reviewCount + 1;
        final updatedRating = ((currentRating * reviewCount) + newRating) / newReviewCount;
        
        transaction.update(salonRef, {
          'rating': updatedRating,
          'reviewCount': newReviewCount,
        });
      }
    });
  }
}