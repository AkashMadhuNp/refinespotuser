import 'package:cloud_firestore/cloud_firestore.dart';

abstract class AppointmentState {}

class AppointmentInitial extends AppointmentState {}

class AppointmentLoading extends AppointmentState {}

class AppointmentLoaded extends AppointmentState {
  final List<Map<String, dynamic>> appointments;
  final String currentFilter;
  
  AppointmentLoaded({
    required this.appointments,
    this.currentFilter = 'all',
  });
}

class AppointmentError extends AppointmentState {
  final String message;
  
  AppointmentError(this.message);
}
