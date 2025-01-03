import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sec_pro/bloc/profilePage/bloc/profile_bloc.dart';
import 'package:sec_pro/screens/loginScreen/login_screen.dart'; 


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Confirm Logout', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to logout?', style: GoogleFonts.montserrat()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.montserrat(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Logout',
              style: GoogleFonts.montserrat(
                color: const Color.fromRGBO(0, 76, 255, 1),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(LoadProfile()),
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          } else if (state is ProfileInitial) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildHeader(context, state),
                      _buildProfileContent(state),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ProfileState state) {
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
                      final shouldLogout = await _showLogoutDialog(context);
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

  Widget _buildProfileContent(ProfileState state) {
    if (state is ProfileLoaded) {
      return ProfileContent(userData: state.userData);
    } else if (state is ProfileLoading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return const SizedBox.shrink();
    }
  }
}

class ProfileContent extends StatelessWidget {
  final Map<String, dynamic> userData;

  const ProfileContent({super.key, required this.userData});

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(0, 76, 255, 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color.fromRGBO(0, 76, 255, 1), size: 24),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey[600]),
            ),
            Text(
              value,
              style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 60,
              child: ClipOval(
                child: Image.asset(
                  "asset/scissor.jpeg",
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            userData['name']?.toUpperCase() ?? "",
            style: GoogleFonts.montserrat(
              fontSize: 24,
              color: const Color.fromRGBO(0, 76, 255, 1),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 100),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildProfileItem(Icons.person, "Username", userData['name'] ?? ""),
                const SizedBox(height: 15),
                _buildProfileItem(Icons.phone, "Phone", userData['phone']?.toString() ?? ""),
                const SizedBox(height: 15),
                _buildProfileItem(Icons.email, "Email", userData['email'] ?? ""),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
