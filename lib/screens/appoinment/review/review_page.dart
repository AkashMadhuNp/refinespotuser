import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sec_pro/screens/appoinment/review/util/review_utils.dart';
import 'package:sec_pro/screens/appoinment/review/widget/action_button.dart';
import 'package:sec_pro/screens/appoinment/review/widget/rating_selector.dart';
import 'package:sec_pro/screens/appoinment/review/widget/review_form.dart';


class ReviewPage extends StatefulWidget {
  final Map<String, dynamic> appointment;

  const ReviewPage({super.key, required this.appointment});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 0;
  bool _isSubmitting = false;
  String _currentUsername = 'Anonymous';
  String _userPhone = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserInfo();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentUserInfo() async {
    try {
      final userInfo = await ReviewUtils.fetchUserInfo();
      if (userInfo != null) {
        setState(() {
          _currentUsername = userInfo.name;
          _userPhone = userInfo.phone;
        });
      }
    } catch (e) {
      print('Error fetching user info: $e');
    }
  }

  void _updateRating(double rating) {
    setState(() {
      _rating = rating;
    });
  }

  void _clearForm() {
    setState(() {
      _rating = 0;
      _reviewController.clear();
    });
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }
    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a review')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ReviewUtils.submitReview(
        context: context,
        appointment: widget.appointment,
        rating: _rating,
        reviewText: _reviewController.text.trim(),
        username: _currentUsername,
        userPhone: _userPhone,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting review: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Write Review',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.appointment['salonName'] ?? 'Unknown Salon',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Rate your experience',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              RatingSelector(
                currentRating: _rating,
                onRatingChanged: _updateRating,
              ),
              const SizedBox(height: 24),
              Text(
                'Write your review',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              ReviewForm(controller: _reviewController),
              const SizedBox(height: 24),
              ActionButtons(
                isSubmitting: _isSubmitting,
                onClear: _clearForm,
                onSubmit: _submitReview,
              ),
            ],
          ),
        ),
      ),
    );
  }
}