import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:sec_pro/constant/constant.dart';

class SignUpHeader extends StatelessWidget {
  const SignUpHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60.0),
      child: SizedBox(
        height: 200,
        child: Row(
          children: [
            Text(
              "CREATE \nACCOUNT",
              style: GoogleFonts.montserrat(
                fontSize: 30,
                color: AppColors.textSecondary, // Changed from Colors.grey to AppColors.textSecondary
              ),
            ),
            Lottie.asset(
              "asset/Login.json",
              height: 300,
              repeat: true,
              reverse: true
            ),
          ],
        ),
      ),
    );
  }
}