//here i am trying to implement that The AppointmentBloc is created when the AppointmentScreen is opened
//It's automatically disposed when the screen is closed



import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sec_pro/screens/appoinment/bloc/appoinment_bloc.dart';
import 'package:sec_pro/screens/appoinment/bloc/appoinment_event.dart';
import 'package:sec_pro/screens/appoinment/bloc/appoinment_state.dart';
import 'package:sec_pro/screens/appoinment/widgets/appoinment_card.dart';
import 'package:sec_pro/screens/appoinment/widgets/empty_state.dart';

class AppointmentScreen extends StatelessWidget {
  const AppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppointmentBloc()..add(LoadAppointmentsEvent()),
      child: AppointmentScreenView(),
    );
  }
}

class AppointmentScreenView extends StatefulWidget {
  const AppointmentScreenView({super.key});

  @override
  State<AppointmentScreenView> createState() => _AppointmentScreenViewState();
}

class _AppointmentScreenViewState extends State<AppointmentScreenView> {
  String _currentFilter = 'all';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Appointments',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _currentFilter = value;
              });
              context.read<AppointmentBloc>().add(FilterAppointmentsEvent(value));
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Appointments'),
              ),
              const PopupMenuItem(
                value: 'upcoming',
                child: Text('Upcoming'),
              ),
              const PopupMenuItem(
                value: 'completed',
                child: Text('Completed'),
              ),
              const PopupMenuItem(
                value: 'pending',
                child: Text('Pending'),
              ),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: BlocBuilder<AppointmentBloc, AppointmentState>(
        builder: (context, state) {
          if (state is AppointmentError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading appointments: ${state.message}',
                  style: GoogleFonts.montserrat(
                    color: Colors.red,
                  ),
                ),
              ),
            );
          }

          return StreamBuilder<QuerySnapshot>(
            stream: context.read<AppointmentBloc>().getAppointmentsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Error loading appointments: ${snapshot.error}',
                      style: GoogleFonts.montserrat(
                        color: Colors.red,
                      ),
                    ),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const EmptyStateWidget();
              }

              final appointments = context
                  .read<AppointmentBloc>()
                  .applyFilter(snapshot.data!.docs, _currentFilter);

              if (appointments.isEmpty) {
                return Center(
                  child: Text(
                    'No ${_currentFilter} appointments found',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  return AppointmentCard(appointment: appointment);
                },
              );
            },
          );
        },
      ),
    );
  }
}