import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileContent extends StatelessWidget {
  final Map<String, dynamic> userData;

  const ProfileContent({super.key, required this.userData});

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(0, 76, 255, 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color.fromRGBO(0, 76, 255, 1), size: 24),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey[600]),
            ),
            Text(
              value,
              style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 60,
              child: ClipOval(
                child: Image.asset(
                  "asset/scissor.jpeg",
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            userData['name']?.toUpperCase() ?? "",
            style: GoogleFonts.montserrat(
              fontSize: 24,
              color: const Color.fromRGBO(0, 76, 255, 1),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 100),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildProfileItem(Icons.person, "Username", userData['name'] ?? ""),
                const SizedBox(height: 15),
                _buildProfileItem(Icons.phone, "Phone", userData['phone']?.toString() ?? ""),
                const SizedBox(height: 15),
                _buildProfileItem(Icons.email, "Email", userData['email'] ?? ""),
              ],
            ),
          ),
        ],
      ),
    );
  }
}