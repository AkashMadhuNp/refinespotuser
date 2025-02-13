import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final bool isLoading;
  final VoidCallback onMenuPressed;

  const HomeHeader({
    Key? key,
    required this.userName,
    required this.isLoading,
    required this.onMenuPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: isLoading
                  ? const CircularProgressIndicator()
                  : RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Hello, ",
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.4,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: userName,
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.4,
                              color: const Color.fromRGBO(0, 76, 255, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          Builder(
            builder: (context) => IconButton(
              onPressed: onMenuPressed,
              icon: const Icon(Icons.menu),
            ),
          ),
        ],
      ),
    );
  }
} 