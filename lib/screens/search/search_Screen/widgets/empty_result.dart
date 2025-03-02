import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyResultsWidget extends StatelessWidget {
  final bool showFilters;
  final VoidCallback onResetFilters;

  const EmptyResultsWidget({
    Key? key,
    required this.showFilters,
    required this.onResetFilters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No salons found matching your filters',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          if (showFilters) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onResetFilters,
              icon: const Icon(Icons.refresh),
              label: Text(
                'Reset All Filters',
                style: GoogleFonts.montserrat(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}