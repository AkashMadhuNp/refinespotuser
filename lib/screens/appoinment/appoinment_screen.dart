import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sec_pro/constant/constant.dart';
import 'package:sec_pro/screens/appoinment/bloc/appoinment_bloc.dart';
import 'package:sec_pro/screens/appoinment/bloc/appoinment_event.dart';
import 'package:sec_pro/screens/appoinment/bloc/appoinment_state.dart';
import 'package:sec_pro/screens/appoinment/widgets/appbar.dart';
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

  void _handleFilterChange(String value) {
    setState(() {
      _currentFilter = value;
    });
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppointmentAppBar(
        currentFilter: _currentFilter,
        onFilterChanged: _handleFilterChange,
      ),

      body: BlocBuilder<AppointmentBloc, AppointmentState>(
        builder: (context, state) {
          if (state is AppointmentError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingLarge),
                child: Text(
                  'Error loading appointments: ${state.message}',
                  style: GoogleFonts.montserrat(
                    color: AppColors.error,
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
                    padding: const EdgeInsets.all(AppSizes.paddingLarge),
                    child: Text(
                      'Error loading appointments: ${snapshot.error}',
                      style: GoogleFonts.montserrat(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                );
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
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(AppSizes.paddingLarge),
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