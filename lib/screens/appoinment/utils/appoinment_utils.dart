import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentUtils {
  static bool isCompletedAppointment(Map<String, dynamic> appointment) {
    return appointment['bookingStatus'] == 'completed';
  }

  static bool isPastAppointment(Map<String, dynamic> appointment) {
    final DateTime appointmentDate = (appointment['appointmentDate'] as Timestamp).toDate();
    return appointmentDate.isBefore(DateTime.now());
  }

  static bool canReview(Map<String, dynamic> appointment) {
    return isCompletedAppointment(appointment) && !appointment.containsKey('reviewed');
  }

  static String formatAmount(dynamic amount) {
    return '₹${amount ?? 0}';
  }

  static List<Map<String, dynamic>> sortAppointmentsByDate(List<QueryDocumentSnapshot> appointments) {
    final List<Map<String, dynamic>> appointmentData = appointments
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    
    appointmentData.sort((a, b) {
      final aDate = (a['appointmentDate'] as Timestamp).toDate();
      final bDate = (b['appointmentDate'] as Timestamp).toDate();
      return bDate.compareTo(aDate);
    });
    
    return appointmentData;
  }
}