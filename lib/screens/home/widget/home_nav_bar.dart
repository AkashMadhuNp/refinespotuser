import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sec_pro/screens/appoinment/appoinment_screen.dart';
import 'package:sec_pro/screens/home/home_screen.dart';
import 'package:sec_pro/screens/profile/profile_screen.dart';
import 'package:sec_pro/screens/search/search_screen.dart';

class BottomNavigatorBar extends StatefulWidget {
  
  const BottomNavigatorBar({super.key, });

  @override
  State<BottomNavigatorBar> createState() => _BottomNavigatorBarState();
}

class _BottomNavigatorBarState extends State<BottomNavigatorBar> {
  int _selectedIndex = 0;

  // Define the pages with the passed username
  late final List<Widget> _pages;
  
  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(),
      SearchScreen(),
      AppoinmentScreen(),
      ProfileScreen()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color.fromARGB(255, 139, 54, 54),
                  Color(0xFF2196F3),
                ],
              ),
            )
          ),
          // Main content
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          
          // Bottom Navigation Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color.fromARGB(255, 12, 1, 52).withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(0, Icons.home_rounded),
                        _buildNavItem(1, Icons.search_rounded),
                        _buildNavItem(2, Icons.calendar_today_rounded),
                        _buildNavItem(3, Icons.person_rounded),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.blueAccent.withOpacity(0.7),
            size: 28,
          ),
        ),
      ),
    );
  }
}