import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PriceRangeWidget extends StatelessWidget {
  final RangeValues currentRangeValues;
  final double minPrice;
  final double maxPrice;
  final Function(RangeValues) onRangeChanged;

  const PriceRangeWidget({
    Key? key,
    required this.currentRangeValues,
    required this.minPrice,
    required this.maxPrice,
    required this.onRangeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        RangeSlider(
          values: currentRangeValues,
          min: minPrice,
          max: maxPrice,
          divisions: 50,
          labels: RangeLabels(
            '₹${currentRangeValues.start.round()}',
            '₹${currentRangeValues.end.round()}',
          ),
          onChanged: onRangeChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '₹${currentRangeValues.start.round()}',
              style: GoogleFonts.montserrat(
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              '₹${currentRangeValues.end.round()}',
              style: GoogleFonts.montserrat(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}