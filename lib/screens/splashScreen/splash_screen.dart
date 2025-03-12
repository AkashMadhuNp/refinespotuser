import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sec_pro/screens/home/widget/home_nav_bar.dart';
import 'package:sec_pro/screens/welcomeScreen/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Lottie.asset("asset/splashscreen.json"),
      nextScreen: _determineInitialScreen(),
      duration: 3000, // Reduced duration for better UX
      splashTransition: SplashTransition.fadeTransition,
    );
  }

  Widget _determineInitialScreen() {
    
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      
      return const BottomNavigatorBar();
    } else {
      
      return const WelcomeScreen();
    }
  }
}