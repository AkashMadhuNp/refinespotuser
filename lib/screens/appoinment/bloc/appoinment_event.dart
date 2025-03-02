abstract class AppointmentEvent {}

class LoadAppointmentsEvent extends AppointmentEvent {}

class FilterAppointmentsEvent extends AppointmentEvent {
  final String filterType; // 'all', 'upcoming', 'completed', etc.
  
  FilterAppointmentsEvent(this.filterType);
}
