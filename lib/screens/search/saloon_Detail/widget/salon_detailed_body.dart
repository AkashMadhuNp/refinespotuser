import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sec_pro/screens/search/saloon_Detail/widget/date_field.dart';
import 'package:sec_pro/screens/search/saloon_Detail/widget/salon_review_preview.dart';
import 'package:sec_pro/screens/search/saloon_Detail/widget/service_container.dart';
import 'package:sec_pro/screens/search/saloon_Detail/widget/time_slot.dart';
import 'package:sec_pro/screens/search/saloon_Detail/widget/working_hours.dart';

class SalonDetailBody extends StatelessWidget {
  final String salonId;
  final List<dynamic> services;
  final String formattedWorkingHours;
  final Map<int, bool> toggleStates;
  final Function(int, bool) onToggleService;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final String opening;
  final String closing;
  final Function(String) onTimeSelected;
  final int totalMinutes;
  final VoidCallback navigateToAllReviews;

  const SalonDetailBody({
    Key? key,
    required this.salonId,
    required this.services,
    required this.formattedWorkingHours,
    required this.toggleStates,
    required this.onToggleService,
    required this.selectedDate,
    required this.onDateSelected,
    required this.opening,
    required this.closing,
    required this.onTimeSelected,
    required this.totalMinutes,
    required this.navigateToAllReviews,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(40),
          topLeft: Radius.circular(40),
        ),
        color: Color(0xFFE3F2FD),
        border: Border(
          top: BorderSide(width: 2),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SalonReviewsPreview(
            salonId: salonId,
            onViewAllReviews: navigateToAllReviews,
          ),
          const SizedBox(height: 20),
          const Divider(),
          Text(
            "Services",
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...services.asMap().entries.map((entry) {
            final index = entry.key;
            final service = entry.value;
            return ServiceCard(
              service: service,
              isSelected: toggleStates[index] ?? false,
              onToggle: (value) => onToggleService(index, value),
            );
          }).toList(),
          const SizedBox(height: 20),
          WorkingHours(workingHours: formattedWorkingHours),
          const SizedBox(height: 20),
          Text(
            "Select Date",
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          DateField(
            selectedDate: selectedDate,
            onDateSelected: onDateSelected,
          ),
          const SizedBox(height: 20),
          TimeSlots(
            opening: opening,
            closing: closing,
            onTimeSelected: onTimeSelected,
            totalDuration: totalMinutes,
            salonId: salonId,
            selectedDate: selectedDate,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}