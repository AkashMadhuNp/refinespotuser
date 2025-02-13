import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingContainer extends StatelessWidget {
  final int totalMinutes;
  final double totalAmount;
  final Function()? onBookPress;

  const BookingContainer({
    super.key,
    required this.totalMinutes,
    required this.totalAmount,
    this.onBookPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Duration: $totalMinutes mins',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Total Amount: \$${totalAmount.toStringAsFixed(2)}',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF004CFF),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: totalAmount > 0 ? onBookPress : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004CFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Book Now',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}