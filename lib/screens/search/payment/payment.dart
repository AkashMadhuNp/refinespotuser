import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sec_pro/constant/constant.dart';
import 'package:sec_pro/screens/search/payment/widget/custom_appbar.dart';
import 'package:sec_pro/screens/search/payment/widget/info_card.dart';
import 'package:sec_pro/screens/search/payment/widget/payment_button.dart';
import 'package:sec_pro/screens/search/payment/widget/salon_info_card.dart';
import 'package:sec_pro/screens/search/payment/widget/section_title.dart';
import 'package:sec_pro/screens/search/payment/widget/service_card_payment.dart';
import 'package:sec_pro/screens/search/payment/widget/total_amount_card.dart';
import 'package:sec_pro/service/payment/stripe_payment_service.dart';

class PaymentPage extends StatefulWidget {
  final List<Map<String, dynamic>> selectedServices;
  final double totalAmount;
  final DateTime selectedDate;
  final String selectedTime;
  final Map<String, dynamic> salonData;

  const PaymentPage({
    Key? key,
    required this.selectedServices,
    required this.totalAmount,
    required this.selectedDate,
    required this.selectedTime,
    required this.salonData,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Debug print to check selected services
    print('Selected Services: ${widget.selectedServices}');
  }

  Future<void> _handlePayment({bool useGooglePay = false}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await StripePaymentService.makePayment(
        amount: widget.totalAmount,
        // currency: 'inr',
        salonData: widget.salonData,
        selectedServices: widget.selectedServices,
        selectedDate: widget.selectedDate,
        selectedTime: widget.selectedTime,
        useGooglePay: useGooglePay,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking confirmed successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Checkout',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingLarge, 
              vertical: AppSizes.paddingSmall
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Salon Info
                SalonInfoCard(salonData: widget.salonData),

                const SizedBox(height: AppSizes.spacingXXLarge),

                // Appointment Details
                const SectionTitle(title: 'Appointment Details'),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return constraints.maxWidth < 600
                        ? Column(
                            children: [
                              InfoCard(
                                title: 'Date',
                                value: DateFormat('MMM dd, yyyy').format(widget.selectedDate),
                                icon: Icons.calendar_today,
                              ),
                              const SizedBox(height: AppSizes.spacingLarge),
                              InfoCard(
                                title: 'Time',
                                value: widget.selectedTime,
                                icon: Icons.access_time,
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: InfoCard(
                                  title: 'Date',
                                  value: DateFormat('MMM dd, yyyy').format(widget.selectedDate),
                                  icon: Icons.calendar_today,
                                ),
                              ),
                              const SizedBox(width: AppSizes.spacingLarge),
                              Expanded(
                                child: InfoCard(
                                  title: 'Time',
                                  value: widget.selectedTime,
                                  icon: Icons.access_time,
                                ),
                              ),
                            ],
                          );
                  },
                ),

                // Selected Services
                const SectionTitle(title: 'Selected Services'),
                ...widget.selectedServices.map((service) => ServiceCard(service: service)),

                // Total Amount
                const SizedBox(height: AppSizes.spacingXXLarge),
                TotalAmountCard(totalAmount: widget.totalAmount),

                // Payment Buttons
                const SizedBox(height: AppSizes.spacingXXXLarge),
                const SectionTitle(title: 'Payment Method'),
                PaymentButton(
                  onPressed: () => _handlePayment(),
                  label: 'Pay with Card',
                  icon: Icons.credit_card,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: AppSizes.spacingXXLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}