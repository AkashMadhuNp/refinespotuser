import 'package:flutter/material.dart';

class AppoinmentScreen extends StatefulWidget {
  const AppoinmentScreen({super.key});

  @override
  State<AppoinmentScreen> createState() => _AppoinmentScreenState();
}

class _AppoinmentScreenState extends State<AppoinmentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("APPOINMENT  SCREEN"),
    );
  }
}