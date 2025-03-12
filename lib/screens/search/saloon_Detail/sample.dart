import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sec_pro/screens/search/payment/payment.dart';
import 'package:sec_pro/screens/search/saloon_Detail/widget/booking_container.dart';
import 'package:sec_pro/screens/search/saloon_Detail/widget/image_container.dart';
import 'package:sec_pro/screens/search/saloon_Detail/widget/review_all_page.dart';
import 'package:sec_pro/screens/search/saloon_Detail/widget/salon_detailed_body.dart';

class SampleDetail extends StatefulWidget {
  final Map<String, dynamic> salonData;

  const SampleDetail({
    super.key,
    required this.salonData,
  });

  @override
  State<SampleDetail> createState() => _SampleDetailState();
}

class _SampleDetailState extends State<SampleDetail> {
  // Firebase instances
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  
  // Stream subscription
  StreamSubscription? _favoriteSubscription;

  // State variables
  bool isFavorite = false;
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();
  String? selectedTimeSlot;
  Map<int, bool> toggleStates = {};
  double totalAmount = 0.0;
  int totalMinutes = 0;

  @override
  void initState() {
    super.initState();
    _initializeFavoriteStatus();
  }

  @override
  void dispose() {
    _favoriteSubscription?.cancel();
    super.dispose();
  }

  void _initializeFavoriteStatus() {
    final user = _auth.currentUser;
    final salonId = _getSalonId();
    
    if (user == null || salonId == null) {
      setState(() => isLoading = false);
      return;
    }

    _favoriteSubscription = _firestore
        .collection('favorites')
        .where('userId', isEqualTo: user.uid)
        .where('salonId', isEqualTo: salonId)
        .snapshots()
        .listen(
          (snapshot) {
            if (mounted) {
              setState(() {
                isFavorite = snapshot.docs.isNotEmpty;
                isLoading = false;
              });
            }
          },
          onError: (error) {
            if (mounted) {
              setState(() => isLoading = false);
              _showSnackBar('Error checking favorite status', isError: true);
            }
          },
        );
  }

  String? _getSalonId() {
    return widget.salonData['uid']?.toString() ?? 
           widget.salonData['id']?.toString() ?? 
           widget.salonData['salonId']?.toString();
  }

  Future<void> toggleFavorite() async {
    final user = _auth.currentUser;
    final salonId = _getSalonId();

    if (user == null) {
      _showSnackBar('Please login to add favorites');
      return;
    }

    if (salonId == null) {
      _showSnackBar('Error: Invalid salon data', isError: true);
      return;
    }

    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      final userFavoritesRef = _firestore
          .collection('favorites')
          .doc(user.uid)
          .collection('userFavorites')
          .doc(salonId);
          
      final docSnapshot = await userFavoritesRef.get();
      
      if (docSnapshot.exists) {
        await userFavoritesRef.delete();
      } else {
        await userFavoritesRef.set({
          'salonId': salonId,
          'timestamp': FieldValue.serverTimestamp(),
          'salonName': widget.salonData['saloonName'] ?? widget.salonData['name'],
          'shopUrl': widget.salonData['shopUrl'],
          'services': widget.salonData['services'],
          'workingHours': widget.salonData['workingHours'],
        });
      }
      
      setState(() {
        isFavorite = !isFavorite;
      });
    } catch (e) {
      _showSnackBar('Error updating favorites', isError: true);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void calculateTotals() {
    final services = widget.salonData['services'] as List<dynamic>? ?? [];
    double amount = 0.0;
    int minutes = 0;

    for (int i = 0; i < services.length; i++) {
      if (toggleStates[i] == true) {
        amount += double.tryParse(services[i]['price']?.toString() ?? '0') ?? 0.0;
        minutes += int.tryParse(services[i]['duration']?.toString() ?? '0') ?? 0;
      }
    }

    setState(() {
      totalAmount = amount;
      totalMinutes = minutes;
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleBooking() {
    if (selectedTimeSlot == null) {
      _showSnackBar('Please select a time slot', isError: true);
      return;
    }

    final List<Map<String, dynamic>> selectedServices = [];
    final services = widget.salonData['services'] as List<dynamic>? ?? [];

    for (int i = 0; i < services.length; i++) {
      if (toggleStates[i] == true) {
        selectedServices.add({
          'name': services[i]['name'] ?? services[i]['serviceName'] ?? 'Unnamed Service',
          'price': services[i]['price'] ?? 0.0,
          'duration': services[i]['duration'] ?? 0,
        });
      }
    }

    if (selectedServices.isEmpty) {
      _showSnackBar('Please select at least one service', isError: true);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          selectedServices: selectedServices,
          totalAmount: totalAmount,
          selectedDate: selectedDate,
          selectedTime: selectedTimeSlot!,
          salonData: widget.salonData,
        ),
      ),
    );
  }

  void _navigateToAllReviews(String salonId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AllReviewsPage(
          salonId: salonId,
          salonName: widget.salonData['saloonName'] ?? widget.salonData['name'] ?? 'Salon',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final services = widget.salonData['services'] as List<dynamic>? ?? [];
    final workingHours = widget.salonData['workingHours'] as Map<String, dynamic>? ?? {};
    
    final opening = workingHours['opening']?.toString() ?? "9:00 AM";
    final closing = workingHours['closing']?.toString() ?? "6:00 PM";
    final formattedWorkingHours = "$opening - $closing";

    final salonId = _getSalonId() ?? '';

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      ImageContainer(
                        salonData: widget.salonData,
                        isFavorite: isFavorite,
                        onFavoriteToggle: toggleFavorite,
                        isLoading: isLoading,
                      ),
                      const SizedBox(height: 100),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: true,
                  child: SalonDetailBody(
                    salonId: salonId,
                    services: services,
                    formattedWorkingHours: formattedWorkingHours,
                    toggleStates: toggleStates,
                    onToggleService: (index, value) {
                      setState(() {
                        toggleStates[index] = value;
                        calculateTotals();
                      });
                    },
                    selectedDate: selectedDate,
                    onDateSelected: (date) => setState(() => selectedDate = date),
                    opening: opening,
                    closing: closing,
                    onTimeSelected: (time) => setState(() => selectedTimeSlot = time),
                    totalMinutes: totalMinutes,
                    navigateToAllReviews: () => _navigateToAllReviews(salonId),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BookingContainer(
                totalMinutes: totalMinutes,
                totalAmount: totalAmount,
                onBookPress: _handleBooking,
              ),
            ),
          ],
        ),
      ),
    );
  }
}