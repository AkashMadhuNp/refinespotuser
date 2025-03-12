import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<bool?> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text('Confirm Logout', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
      content: Text('Are you sure you want to logout?', style: GoogleFonts.montserrat()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel', style: GoogleFonts.montserrat(color: Colors.grey[600])),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            'Logout',
            style: GoogleFonts.montserrat(
              color: const Color.fromRGBO(0, 76, 255, 1),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}