import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sec_pro/screens/appoinment/bloc/appoinment_event.dart';
import 'package:sec_pro/screens/appoinment/bloc/appoinment_state.dart';
import 'package:sec_pro/screens/appoinment/utils/appoinment_utils.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  
  AppointmentBloc({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : 
    _firestore = firestore ?? FirebaseFirestore.instance,
    _auth = auth ?? FirebaseAuth.instance,
    super(AppointmentInitial()) {
    on<LoadAppointmentsEvent>(_onLoadAppointments);
    on<FilterAppointmentsEvent>(_onFilterAppointments);
  }
  
  Stream<QuerySnapshot> getAppointmentsStream() {
    return _firestore
        .collection('appointments')
        .where('userId', isEqualTo: _auth.currentUser?.uid)
        .snapshots();
  }
  
  void _onLoadAppointments(
    LoadAppointmentsEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentLoading());
    
    try {
      // We don't actually fetch the data here since we'll use a StreamBuilder
      // with the getAppointmentsStream method for real-time updates.
      // This is just to initialize the state.
      emit(AppointmentLoaded(appointments: []));
    } catch (e) {
      emit(AppointmentError(e.toString()));
    }
  }
  
  void _onFilterAppointments(
    FilterAppointmentsEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    if (state is AppointmentLoaded) {
      final currentState = state as AppointmentLoaded;
      emit(AppointmentLoaded(
        appointments: currentState.appointments,
        currentFilter: event.filterType,
      ));
    }
  }
  
  List<Map<String, dynamic>> applyFilter(
    List<QueryDocumentSnapshot> docs,
    String filterType,
  ) {
    final allAppointments = AppointmentUtils.sortAppointmentsByDate(docs);
    
    switch (filterType) {
      case 'upcoming':
        return allAppointments.where((appointment) => 
          !AppointmentUtils.isPastAppointment(appointment)).toList();
      case 'completed':
        return allAppointments.where((appointment) => 
          AppointmentUtils.isCompletedAppointment(appointment)).toList();
      case 'pending':
        return allAppointments.where((appointment) => 
          appointment['bookingStatus'] == 'pending').toList();
      case 'all':
      default:
        return allAppointments;
    }
  }
}
