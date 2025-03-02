import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sec_pro/screens/appoinment/review/review_page.dart';

class ReviewDialog extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const ReviewDialog({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        'Review Service',
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        'Would you like to review this service?',
        style: GoogleFonts.montserrat(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Not Now',
            style: GoogleFonts.montserrat(
              color: Colors.grey,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // Navigate to review page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReviewPage(appointment: appointment),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Review',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}