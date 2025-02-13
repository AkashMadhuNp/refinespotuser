import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sec_pro/screens/appoinment/appoinment_screen.dart';
import 'package:sec_pro/screens/profile/profile_screen.dart';
import 'package:sec_pro/screens/search/search_Screen/search_screen.dart';

class HomeDrawer extends StatelessWidget {
  final String userName;
  final String email;
  final String phoneNumber;

  const HomeDrawer({
    Key? key,
    required this.userName,
    required this.email,
    required this.phoneNumber,
  }) : super(key: key);

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
          _buildDrawerItem(context, Icons.bookmark, 'Bookmarks', () => Navigator.pop(context)),
          _buildDrawerItem(context, Icons.monetization_on, 'Wallet', () => Navigator.pop(context)),
          _buildDrawerItem(context, Icons.note_rounded, 'Term & Condition', () => Navigator.pop(context)),
          _buildDrawerItem(context, Icons.headset_mic, 'Customer Care', () => Navigator.pop(context)),
          _buildDrawerItem(context, Icons.exit_to_app, 'Logout', () => Navigator.pop(context)),
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
