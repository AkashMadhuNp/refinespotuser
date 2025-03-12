import 'package:flutter/material.dart';
import 'package:sec_pro/screens/search/saloon_Detail/widget/date_picker.dart';

class DateField extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DateField({
    Key? key,
    required this.selectedDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      controller: TextEditingController(
        text: "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.blue.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        suffixIcon: const Icon(Icons.calendar_today),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => CustomDatePicker(
            initialDate: selectedDate,
            onDateSelected: onDateSelected,
          ),
        );
      },
    );
  }
}