import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sec_pro/screens/appoinment/widgets/review_dialog.dart';
import 'package:sec_pro/screens/appoinment/widgets/service_list.dart';
import 'package:sec_pro/screens/appoinment/widgets/status_bar.dart';

class AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const AppointmentCard({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateTime appointmentDate = (appointment['appointmentDate'] as Timestamp).toDate();
    final bool isPastAppointment = appointmentDate.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPastAppointment 
              ? [Colors.grey[100]!, Colors.grey[200]!]
              : [
                  const Color(0xFF1A237E).withOpacity(0.05),
                  const Color(0xFF1A237E).withOpacity(0.15),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Bar
          StatusBar(
            appointment: appointment,
            isPastAppointment: isPastAppointment,
            onReviewTap: () => _showReviewDialog(context, appointment),
          ),

          // Appointment Details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment['salonName'] ?? 'Unknown Salon',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Date display
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('EEEE, MMMM d, y').format(appointmentDate),
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Services Section
                Text(
                  'Services',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                ServicesList(services: appointment['services'] ?? []),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(BuildContext context, Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ReviewDialog(appointment: appointment),
    );
  }
}