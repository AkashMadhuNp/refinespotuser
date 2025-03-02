import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sec_pro/screens/search/payment/key.dart';

class StripePaymentService {
  static String baseUrl = 'https://api.stripe.com/v1';
  
  static Map<String, String> headers = {
    'Authorization': 'Bearer ${STRIPE_SECRET_KEY}',
    'Content-Type': 'application/x-www-form-urlencoded'
  };

  static Future<void> saveAppointment({
    required Map<String, dynamic> salonData,
    required List<Map<String, dynamic>> selectedServices,
    required DateTime selectedDate,
    required String selectedTime,
    required double totalAmount,
    required String paymentIntentId,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final timeSlotParts = selectedTime.split(' - ');
      final startTime = timeSlotParts[0];
      final endTime = timeSlotParts.length > 1 ? timeSlotParts[1] : '';

      final appointmentData = {
        'userId': user.uid,
        'userEmail': user.email,
        'salonId': salonData['id'] ?? salonData['uid'] ?? '',
        'salonName': salonData['name'] ?? salonData['saloonName'] ?? '',
        'salonLocation': salonData['location'] ?? '',
        'appointmentDate': Timestamp.fromDate(selectedDate),
        'timeSlot': selectedTime,
        'startTime': startTime,
        'endTime': endTime,
        'services': selectedServices.map((service) => {
          'serviceName': service['serviceName'] ?? service['name'] ?? '',
          'price': service['price'],
          'duration': service['duration'],
        }).toList(),
        'totalAmount': totalAmount,
        'paymentStatus': 'completed',
        'paymentIntentId': paymentIntentId,
        'bookingStatus': 'confirmed',
        'createdAt': FieldValue.serverTimestamp(),
        'currency': 'inr', // Add currency information
      };

      await FirebaseFirestore.instance
          .collection('appointments')
          .add(appointmentData);

    } catch (e) {
      throw Exception('Failed to save appointment: $e');
    }
  }

  static Future<Map<String, dynamic>> createPaymentIntent(
    double amount,
    String currency,
  ) async {
    try {
      // For INR, amount needs to be in paise (1 INR = 100 paise)
      final amountInSmallestUnit = (amount * 100).round().toString();
      
      Map<String, dynamic> body = {
        'amount': amountInSmallestUnit,
        'currency': currency.toLowerCase(),
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
        Uri.parse('$baseUrl/payment_intents'),
        headers: headers,
        body: body,
      );
      return jsonDecode(response.body);
    } catch (err) {
      throw Exception('Failed to create payment intent: $err');
    }
  }

  static Future<void> makePayment({
    required double amount,
    required Map<String, dynamic> salonData,
    required List<Map<String, dynamic>> selectedServices,
    required DateTime selectedDate,
    required String selectedTime,
    bool useGooglePay = false,
  }) async {
    try {
      // Set currency to INR
      const String currency = 'inr';
      
      // Create payment intent
      Map<String, dynamic> paymentIntent = 
          await createPaymentIntent(amount, currency);

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'REFINE SPOT',
          style: ThemeMode.system,
          googlePay: useGooglePay ? PaymentSheetGooglePay(
            merchantCountryCode: 'IN', // Changed to India
            currencyCode: currency.toUpperCase(),
            testEnv: true,
          ) : null,
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();
      
      // If payment is successful, save the appointment
      await saveAppointment(
        salonData: salonData,
        selectedServices: selectedServices,
        selectedDate: selectedDate,
        selectedTime: selectedTime,
        totalAmount: amount,
        paymentIntentId: paymentIntent['id'],
      );
      
    } catch (e) {
      throw Exception('Payment failed: $e');
    }
  }
}