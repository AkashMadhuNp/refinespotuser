import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final bool showFilters;
  final VoidCallback onFilterToggle;

  const SearchBarWidget({
    Key? key,
    required this.controller,
    required this.onChanged,
    required this.showFilters,
    required this.onFilterToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "Search",
          style: GoogleFonts.montserrat(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.4,
            color: const Color.fromRGBO(0, 76, 255, 1),
          ),
        ),
        const SizedBox(width: 40),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: GoogleFonts.montserrat(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.blue.shade100,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 16.0,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.filter_list,
                      color: showFilters ? Colors.blue : Colors.grey.shade600,
                    ),
                    onPressed: onFilterToggle,
                  ),
                  Icon(
                    Icons.search,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}