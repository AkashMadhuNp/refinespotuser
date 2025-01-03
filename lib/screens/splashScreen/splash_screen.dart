import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sec_pro/screens/home/widget/home_nav_bar.dart';
import 'package:sec_pro/screens/welcomeScreen/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<Widget> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    return isLoggedIn ? const BottomNavigatorBar() : const WelcomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: checkLoginStatus(),
      builder: (context, snapshot) {
        return AnimatedSplashScreen(
          splash: Lottie.asset("asset/splashscreen.json"),
          nextScreen: snapshot.data ?? const WelcomeScreen(),
          duration: 6000,
        );
      },
    );
  }
}