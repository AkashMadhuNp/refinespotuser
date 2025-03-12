import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sec_pro/screens/appoinment/bloc/appoinment_bloc.dart';
import 'package:sec_pro/screens/appoinment/bloc/appoinment_event.dart';

class AppointmentAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentFilter;
  final Function(String) onFilterChanged;

  const AppointmentAppBar({
    Key? key,
    required this.currentFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
            onFilterChanged(value);
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}