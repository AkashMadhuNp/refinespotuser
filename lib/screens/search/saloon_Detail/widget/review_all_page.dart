import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sec_pro/screens/search/saloon_Detail/widget/review_card.dart';

class AllReviewsPage extends StatefulWidget {
  final String salonId;
  final String salonName;
  
  const AllReviewsPage({
    Key? key,
    required this.salonId,
    required this.salonName,
  }) : super(key: key);

  @override
  State<AllReviewsPage> createState() => _AllReviewsPageState();
}

class _AllReviewsPageState extends State<AllReviewsPage> {
  double avgRating = 0;
  int totalReviews = 0;
  Map<int, int> ratingDistribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

  @override
  void initState() {
    super.initState();
    _calculateAverageRating();
  }

  Future<void> _calculateAverageRating() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('review')
          .where('salonId', isEqualTo: widget.salonId)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        setState(() {
          avgRating = 0;
          totalReviews = 0;
        });
        return;
      }
      
      double totalRating = 0;
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final rating = (data['rating'] ?? 0).toInt();
        totalRating += rating;
        
        // Update rating distribution
        if (rating >= 1 && rating <= 5) {
          ratingDistribution[rating] = (ratingDistribution[rating] ?? 0) + 1;
        }
      }
      
      setState(() {
        totalReviews = querySnapshot.docs.length;
        avgRating = totalRating / totalReviews;
      });
    } catch (e) {
      print('Error calculating average rating: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reviews for ${widget.salonName}',
          style: GoogleFonts.montserrat(),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildRatingSummary(),
          const Divider(height: 1),
          Expanded(
            child: _buildAllReviews(),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                avgRating.toStringAsFixed(1),
                style: GoogleFonts.montserrat(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              RatingBarIndicator(
                rating: avgRating,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                itemCount: 5,
                itemSize: 24,
              ),
              const SizedBox(height: 4),
              Text(
                '$totalReviews reviews',
                style: GoogleFonts.montserrat(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1].map((rating) {
                final count = ratingDistribution[rating] ?? 0;
                final percentage = totalReviews > 0 
                    ? (count / totalReviews) * 100 
                    : 0.0;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        '$rating',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getRatingColor(rating),
                          ),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        count.toString(),
                        style: GoogleFonts.montserrat(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 5: return Colors.green;
      case 4: return Colors.lightGreen;
      case 3: return Colors.amber;
      case 2: return Colors.orange;
      case 1: return Colors.red;
      default: return Colors.grey;
    }
  }

  Widget _buildAllReviews() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('review')
          .where('salonId', isEqualTo: widget.salonId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final reviews = snapshot.data?.docs ?? [];
        
        if (reviews.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No reviews yet',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index].data() as Map<String, dynamic>;
            return ReviewCard(review: review);
          },
        );
      },
    );
  }
}
