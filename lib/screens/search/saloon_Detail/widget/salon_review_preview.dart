import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sec_pro/screens/search/saloon_Detail/widget/review_card.dart';

// 1. Create a SalonReviews widget to display reviews in the salon detail page
class SalonReviewsPreview extends StatelessWidget {
  final String salonId;
  final VoidCallback onViewAllReviews;
  
  const SalonReviewsPreview({
    Key? key,
    required this.salonId,
    required this.onViewAllReviews,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Reviews",
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: onViewAllReviews,
              child: Text(
                "View All",
                style: GoogleFonts.montserrat(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildReviewsList(),
      ],
    );
  }

  Widget _buildReviewsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('review')
          .where('salonId', isEqualTo: salonId)
          .orderBy('createdAt', descending: true)
          .limit(3) // Show only 3 most recent reviews
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
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text('No reviews yet')),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
