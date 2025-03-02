import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      'Welcome to Our Service',
                      'By using our app, you agree to these terms and conditions. Please read them carefully before using our services.',
                    ),
                    _buildSection(
                      '1. Acceptance of Terms',
                      'By accessing and using this application, you accept and agree to be bound by the terms and provisions of this agreement.',
                    ),
                    _buildSection(
                      '2. User Account',
                      'To use certain features of the app, you must register for an account. You agree to:\n'
                      '• Provide accurate information\n'
                      '• Maintain the security of your account\n'
                      '• Promptly update any changes to your information\n'
                      '• Accept responsibility for all activities that occur under your account',
                    ),
                    _buildSection(
                      '3. Booking and Cancellation',
                      '• Appointments must be booked at least 2 hours in advance\n'
                      '• Cancellations must be made at least 1 hour before the appointment\n'
                      '• Late cancellations may incur a fee\n'
                      '• No-shows will be charged the full service amount',
                    ),
                    _buildSection(
                      '4. Payment Terms',
                      '• Payment is required at the time of booking\n'
                      '• We accept card payment methods including credit cards and link card payments\n'
                      '• All prices are subject to change without notice',
                    ),
                    _buildSection(
                      '5. User Conduct',
                      'You agree not to:\n'
                      '• Violate any applicable laws or regulations\n'
                      '• Interfere with or disrupt the service\n'
                      '• Harass or harm other users or service providers\n'
                      '• Submit false or misleading information',
                    ),
                    _buildSection(
                      '6. Privacy Policy',
                      'Your privacy is important to us. Our Privacy Policy explains how we collect, use, and protect your personal information.',
                    ),
                    _buildSection(
                      '7. Modifications',
                      'We reserve the right to modify these terms at any time. Continued use of the service after any changes constitutes acceptance of the new terms.',
                    ),
                    _buildSection(
                      '8. Contact Information',
                      'If you have any questions about these Terms and Conditions, please contact us at:\n'
                      'Email: 002akashakz@gmail.com\n'
                      'Phone: +91-7025522432',
                    ),
                    const SizedBox(height: 20),
                    _buildLastUpdated(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 8),
          Text(
            "Terms & Conditions",
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color.fromRGBO(0, 76, 255, 1),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          content,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            height: 1.5,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildLastUpdated() {
    return Center(
      child: Text(
        'Last Updated: February 20, 2025',
        style: GoogleFonts.montserrat(
          fontSize: 12,
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}