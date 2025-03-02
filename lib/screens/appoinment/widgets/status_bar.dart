import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusBar extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final bool isPastAppointment;
  final VoidCallback onReviewTap;

  const StatusBar({
    Key? key,
    required this.appointment,
    required this.isPastAppointment,
    required this.onReviewTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String timeSlot = appointment['timeSlot'] ?? 'No slot selected';
    final String bookingStatus = appointment['bookingStatus'] ?? '';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: isPastAppointment
              ? [Colors.grey, Colors.grey.shade700]
              : [Colors.blue.shade700, Colors.indigo.shade900],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status indicator
              Row(
                children: [
                  Icon(
                    bookingStatus == "completed" ? Icons.check_circle : Icons.calendar_today,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    bookingStatus == 'completed' ? 'Completed' : 'Upcoming',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              // Price and review button container
              Row(
                children: [
                  Text(
                    '₹${appointment['totalAmount'] ?? 0}',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (bookingStatus == "completed") ...[
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: onReviewTap,
                        icon: const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 24,
                        ),
                        tooltip: 'Review Service',
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Time slot indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  timeSlot,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}