import 'package:flutter/material.dart';
import 'package:sec_pro/screens/search/payment/payment.dart';

class BookingService {
  static List<Map<String, dynamic>> getSelectedServices(
    List<dynamic> services,
    Map<int, bool> toggleStates,
  ) {
    final List<Map<String, dynamic>> selectedServices = [];

    for (int i = 0; i < services.length; i++) {
      if (toggleStates[i] == true) {
        selectedServices.add({
          'name': services[i]['name'] ?? services[i]['serviceName'] ?? 'Unnamed Service',
          'price': services[i]['price'] ?? 0.0,
          'duration': services[i]['duration'] ?? 0,
        });
      }
    }

    return selectedServices;
  }

  static void calculateTotals(
    List<dynamic> services,
    Map<int, bool> toggleStates,
    Function(double, int) onResult,
  ) {
    double amount = 0.0;
    int minutes = 0;

    for (int i = 0; i < services.length; i++) {
      if (toggleStates[i] == true) {
        amount += double.tryParse(services[i]['price']?.toString() ?? '0') ?? 0.0;
        minutes += int.tryParse(services[i]['duration']?.toString() ?? '0') ?? 0;
      }
    }

    onResult(amount, minutes);
  }

  static void navigateToPayment(
    BuildContext context,
    List<Map<String, dynamic>> selectedServices,
    double totalAmount,
    DateTime selectedDate,
    String selectedTime,
    Map<String, dynamic> salonData,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          selectedServices: selectedServices,
          totalAmount: totalAmount,
          selectedDate: selectedDate,
          selectedTime: selectedTime,
          salonData: salonData,
        ),
      ),
    );
  }
}