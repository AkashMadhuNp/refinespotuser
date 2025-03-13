import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sec_pro/bloc/profilePage/bloc/profile_bloc.dart';
import 'package:sec_pro/screens/loginScreen/login_screen.dart';
import 'package:sec_pro/screens/profile/widgets/profile_content.dart';
import 'package:sec_pro/screens/profile/widgets/profile_header.dart';
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      buildProfileHeader(context, state),  
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