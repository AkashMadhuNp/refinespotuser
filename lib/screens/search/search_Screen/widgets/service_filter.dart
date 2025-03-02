import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceFilterWidget extends StatelessWidget {
  final bool isLoading;
  final List<String> availableServices;
  final String? selectedService;
  final Function(String?) onServiceChanged;

  const ServiceFilterWidget({
    Key? key,
    required this.isLoading,
    required this.availableServices,
    required this.selectedService,
    required this.onServiceChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service',
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        isLoading
            ? Center(
                child: SizedBox(
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              )
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedService,
                    hint: Text(
                      'Select a service',
                      style: GoogleFonts.montserrat(),
                    ),
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    elevation: 16,
                    style: GoogleFonts.montserrat(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text(
                          'All Services',
                          style: GoogleFonts.montserrat(),
                        ),
                      ),
                      ...availableServices.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ],
                    onChanged: onServiceChanged,
                  ),
                ),
              ),
      ],
    );
  }
}