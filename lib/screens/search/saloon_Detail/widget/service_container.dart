import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final bool isSelected;
  final ValueChanged<bool> onToggle;

  const ServiceCard({
    super.key,
    required this.service,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFF004CFF) : Colors.black,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
        title: Text(
          service["serviceName"] ?? '',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          '${service['duration']} mins - \$${service['price']}',
          style: GoogleFonts.montserrat(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        trailing: Switch.adaptive(
          value: isSelected,
          activeColor: const Color(0xFF004CFF),
          onChanged: onToggle,
        ),
      ),
    );
  }
}
