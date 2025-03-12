import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sec_pro/bloc/profilePage/bloc/profile_bloc.dart';
import 'profile_dialogs.dart';

Widget buildProfileHeader(BuildContext context, ProfileState state) {
  return Container(
    height: 100,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: Text(
            "Profile",
            style: GoogleFonts.montserrat(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
            ),
          ),
        ),
        CircleAvatar(
          radius: 30,
          backgroundColor: const Color.fromRGBO(0, 76, 255, 1),
          child: state is ProfileLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : IconButton(
                  onPressed: () async {
                    final shouldLogout = await showLogoutDialog(context);
                    if (shouldLogout == true) {
                      // ignore: use_build_context_synchronously
                      context.read<ProfileBloc>().add(LogoutRequested());
                    }
                  },
                  icon: const Icon(Icons.exit_to_app, size: 30, color: Colors.white),
                ),
        ),
      ],
    ),
  );
}