import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sec_pro/models/salon_model.dart';
import 'package:sec_pro/screens/search/saloon_Detail/widget/review_all_page.dart';

class SalonListItem extends StatelessWidget {
  final Salon salon;

  const SalonListItem({
    Key? key,
    required this.salon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to AllReviewsPage when the card is tapped
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AllReviewsPage(
                salonId: salon.id,
                salonName: salon.name,
              ),
            ),
          );
        },
        child: Row(
          children: [
            // Circular image
            Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: Image.network(
                    salon.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.store, color: Colors.grey[400], size: 30),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Salon details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      salon.name,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      salon.address,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            // Rating
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 18,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    salon.rating.toStringAsFixed(1),
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}