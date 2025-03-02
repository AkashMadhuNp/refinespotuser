import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewForm extends StatelessWidget {
  final TextEditingController controller;

  const ReviewForm({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: 'Share your experience...',
          hintStyle: GoogleFonts.montserrat(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}