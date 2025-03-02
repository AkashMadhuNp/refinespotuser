import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sec_pro/bloc/profilePage/bloc/profile_bloc.dart';
import 'package:sec_pro/screens/appoinment/appoinment_screen.dart';
import 'package:sec_pro/screens/home/widget/bookmark_screen.dart';
import 'package:sec_pro/screens/home/widget/customer_care.dart';
import 'package:sec_pro/screens/home/widget/termsandcondition.dart';
import 'package:sec_pro/screens/loginScreen/login_screen.dart';

import 'package:sec_pro/screens/profile/profile_screen.dart';
import 'package:sec_pro/screens/search/search_Screen/search_screen.dart';
import 'package:sec_pro/service/auth/auth_service.dart';

class HomeDrawer extends StatelessWidget {
  final String userName;
  final String email;
  final String phoneNumber;
  final AuthServices _authServices = AuthServices(); //

   HomeDrawer({
    Key? key,
    required this.userName,
    required this.email,
    required this.phoneNumber,
  }) : super(key: key);


  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)
        ),
        title: Text(
          'Confirm Logout',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.montserrat()
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.montserrat(color: Colors.grey[600])
            )
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Logout',
              style: GoogleFonts.montserrat(
                color: const Color.fromRGBO(0, 76, 255, 1),
                fontWeight: FontWeight.bold,
              ),
            )
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await _authServices.signOut();
      if (context.mounted) {
        // Navigate to login screen and remove all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to logout: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),
          _buildDrawerItem(context, Icons.home, 'Home', () => Navigator.of(context).pop()),
          _buildDrawerItem(context, Icons.search, 'Search', 
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen()))),
          _buildDrawerItem(context, Icons.calendar_month, 'Appointment', 
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => AppointmentScreen()))),
          _buildDrawerItem(context, Icons.person_2_outlined, 'Profile', 
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()))),
          _buildDrawerItem(
                context,
                Icons.bookmark,
                'Bookmarks',
                () {
                  Navigator.pop(context); // Close drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BookmarksScreen()),
                  );
                },
              ),

              _buildDrawerItem(
                  context,
                  Icons.note_rounded,
                  'Term & Condition',
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TermsAndConditionsScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  Icons.headset_mic,
                  'Customer Care',
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CustomerServiceScreen()),
                    );
                  },
                ),          
              
                    _buildDrawerItem(
            context,
            Icons.exit_to_app,
            'Logout',
            () async {
              final shouldLogout = await _showLogoutDialog(context);
              if (shouldLogout == true) {
                if (context.mounted) {
                  await _handleLogout(context);
                }
              }
            }
          ),


        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return SizedBox(
      height: 200,
      child: DrawerHeader(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 0, 10, 18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                radius: 30,
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
              userName,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.4,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              email,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                letterSpacing: 0.4,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Phone: $phoneNumber',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                letterSpacing: 0.4,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}
