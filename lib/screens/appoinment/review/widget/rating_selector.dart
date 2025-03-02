import 'package:flutter/material.dart';

class RatingSelector extends StatelessWidget {
  final double currentRating;
  final Function(double) onRatingChanged;

  const RatingSelector({
    Key? key,
    required this.currentRating,
    required this.onRatingChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            onRatingChanged(index + 1.0);
          },
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Icon(
              index < currentRating ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 40,
            ),
          ),
        );
      }),
    );
  }
}