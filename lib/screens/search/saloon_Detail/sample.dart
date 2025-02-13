import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sec_pro/screens/search/payment/payment.dart';
import 'package:sec_pro/screens/search/saloon_Detail/widget/booking_container.dart';
import 'package:sec_pro/screens/search/saloon_Detail/widget/date_picker.dart';
import 'package:sec_pro/screens/search/saloon_Detail/widget/image_container.dart';
import 'package:sec_pro/screens/search/saloon_Detail/widget/service_container.dart';
import 'package:sec_pro/screens/search/saloon_Detail/widget/time_slot.dart';
import 'package:sec_pro/screens/search/saloon_Detail/widget/working_hours.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sec_pro/service/favorite/fav_service.dart';

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // late final FavoriteService _favoriteService;
  late final FavoritesService _favoritesService;

  bool isFavorite = false;
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();
  String? selectedTimeSlot;
  Map<int, bool> toggleStates = {};
  double totalAmount = 0.0;
  int totalMinutes = 0;


  // void _debugPrintSalonData() {
  //   print('Salon Data Debug:');
  //   print('Raw salon data: ${widget.salonData}');
  //   print('UID: ${widget.salonData['uid']}');
  //   print('ID: ${widget.salonData['id']}');
  //   print('SalonId: ${widget.salonData['salonId']}');
  // }

  
 
@override
  void initState() {
    super.initState();
    
    _favoritesService=FavoritesService();
    _initializeFavoriteStatus();
  }


void _initializeFavoriteStatus() {
    if (_auth.currentUser == null) {
      setState(() => isLoading = false);
      return;
    }

    final salonId = widget.salonData['uid']?.toString();
    if (salonId == null) {
      setState(() => isLoading = false);
      return;
    }

    _favoritesService
        .isSalonFavorite(salonId)
        .listen(
          (isFav) {
            if (mounted) {
              setState(() {
                isFavorite = isFav;
                isLoading = false;
              });
            }
          },
          onError: (error) {
            if (mounted) {
              setState(() => isLoading = false);
            }
          },
        );
  }


Future<void> toggleFavorite() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        _showSnackBar('Please login to add favorites');
        return;
      }

      final salonId = _getSalonId();
      if (salonId == null) {
        _showSnackBar('Error: Could not identify salon');
        return;
      }

      if (!isFavorite) {
        await _addToFavorites(salonId);
      } else {
        await _removeFromFavorites(salonId);
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  String? _getSalonId() {
    return widget.salonData['uid']?.toString() ?? 
           widget.salonData['id']?.toString() ?? 
           widget.salonData['salonId']?.toString() ??
           widget.salonData['userId']?.toString();
  }

  Future<void> _addToFavorites(String salonId) async {
    try {
      final enrichedSalonData = _prepareEnrichedSalonData(salonId);
      
      final canAdd = await _favoritesService.canAddMoreFavorites();
      if (!canAdd) {
        _showSnackBar('Maximum favorites limit reached', isError: true);
        return;
      }
      
      await _favoritesService.addToFavorites(enrichedSalonData);
      _showSnackBar('Added to favorites');
    } catch (e) {
      if (e.toString().contains('already in favorites')) {
        _showSnackBar('Salon is already in your favorites');
      } else {
        rethrow;
      }
    }
  }

  Map<String, dynamic> _prepareEnrichedSalonData(String salonId) {
    return {
      ...widget.salonData,
      'salonId': salonId,
      'uid': salonId,
      'id': salonId,
      'email': widget.salonData['email'] ?? '',
      'name': widget.salonData['name'] ?? '',
      'saloonName': widget.salonData['saloonName'] ?? widget.salonData['name'] ?? '',
    };
  }

  Future<void> _removeFromFavorites(String salonId) async {
    await _favoritesService.removeFromFavorites(salonId);
    _showSnackBar('Removed from favorites');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }



  void calculateTotals() {
    final services = widget.salonData['services'] as List<dynamic>;
    double amount = 0.0;
    int minutes = 0;

    for (int i = 0; i < services.length; i++) {
      if (toggleStates[i] == true) {
        amount += double.parse(services[i]['price'].toString());
        minutes += int.parse(services[i]['duration'].toString());
      }
    }

    setState(() {
      totalAmount = amount;
      totalMinutes = minutes;
    });
  }

  void onTimeSelected(String time) {
    setState(() {
      selectedTimeSlot = time;
    });
  }


     


  

  

  (String, String) _extractWorkingHours() {
    try {
      final workingHours = widget.salonData['workingHours'] as Map<String, dynamic>;
      
      // Extract opening and closing times with AM/PM format
      String opening = workingHours['opening'].toString().trim();
      String closing = workingHours['closing'].toString().trim();
      
      print('Extracted opening: $opening');
      print('Extracted closing: $closing');
      
      // Already in 12-hour format, just normalize the format
      String normalizeTime(String time) {
        time = time.replaceAll('"', '').trim();
        // Ensure proper spacing between time and AM/PM
        return time.replaceAll(RegExp(r'([AP]M)'), ' ').trim();
      }

      final result = (normalizeTime(opening), normalizeTime(closing));
      print('Final times: $result');
      return result;
    } catch (e) {
      print('Error parsing working hours: $e');
      return ("9:00 AM", "6:00 PM"); // fallback default values
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = widget.salonData['services'] as List<dynamic>;
    
    // Safely extract working hours with null checks and type casting
    String opening = "9:00 AM";  // default value
    String closing = "6:00 PM";  // default value
    
    try {
      if (widget.salonData['workingHours'] != null) {
        final workingHours = widget.salonData['workingHours'] as Map<String, dynamic>;
        opening = workingHours['opening']?.toString() ?? "9:00 AM";
        closing = workingHours['closing']?.toString() ?? "6:00 PM";
      }
    } catch (e) {
      print('Error extracting working hours: $e');
    }

    // Format working hours for display
    final formattedWorkingHours = "$opening - $closing";
    
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // ImageContainer(
                      //   salonData: widget.salonData,
                      //   isFavorite: isFavorite,
                      //   onFavoriteToggle: (){}, 
                      //   isLoading: isLoading,
                      // ),

                      ImageContainer(
                        salonData: widget.salonData,
                        isFavorite: isFavorite,
                        onFavoriteToggle: toggleFavorite,
                        isLoading: isLoading,
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
                     
                SliverFillRemaining(
                  hasScrollBody: true,
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(40),
                        topLeft: Radius.circular(40),
                      ),
                      color: Color(0xFFE3F2FD),
                      border: Border(
                        top: BorderSide(width: 2),
                      ),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Text(
                          "Services",
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...services.map((service) {
                          final index = services.indexOf(service);
                          return ServiceCard(
                            service: service,
                            isSelected: toggleStates[index] ?? false,
                            onToggle: (value) {
                              setState(() {
                                toggleStates[index] = value;
                                calculateTotals();
                              });
                            },
                          );
                        }).toList(),
                        const SizedBox(height: 20),
                        WorkingHours(
                          workingHours: formattedWorkingHours,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Select Date",
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
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
                                onDateSelected: (date) {
                                  setState(() {
                                    selectedDate = date;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        TimeSlots(
                          opening: opening,
                          closing: closing,
                          onTimeSelected: onTimeSelected,
                          totalDuration: totalMinutes,
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
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
                onBookPress: () {
                  // Check if time slot is selected
                  if (selectedTimeSlot == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a time slot'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Get selected services
                  final List<Map<String, dynamic>> selectedServices = [];
                  final services = widget.salonData['services'] as List<dynamic>;
                  
                  // for (int i = 0; i < services.length; i++) {
                  //   if (toggleStates[i] == true) {
                  //     selectedServices.add({
                  //       'name': services[i]['name'],
                  //       'price': services[i]['price'],
                  //       'duration': services[i]['duration'],
                  //     });
                  //   }
                  // }

                  // Add some debug prints to see the data
                  for (int i = 0; i < services.length; i++) {
                    if (toggleStates[i] == true) {
                      // Debug print to see what's in services[i]
                      print('Service being added: ${services[i]}');
                      
                      selectedServices.add({
                        'name': services[i]['name'] ?? services[i]['serviceName'] ?? 'Unnamed Service', // Try alternative field name and provide fallback
                        'price': services[i]['price'] ?? 0.0,
                        'duration': services[i]['duration'] ?? 0,
                      });
                      
                      // Debug print to verify what was added
                      print('Added service: ${selectedServices.last}');
                    }
                  }
                  // Check if any service is selected
                  if (selectedServices.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select at least one service'),
                        backgroundColor: Colors.red,
                      ),
                    );
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}


class FavoriteService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FavoriteService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Stream<bool> isFavorite(String salonId) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(false);

    return _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .where('salonId', isEqualTo: salonId)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }
}


