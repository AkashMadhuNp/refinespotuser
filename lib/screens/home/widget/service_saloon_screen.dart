import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sec_pro/models/salon_model.dart';
import 'package:sec_pro/screens/home/widget/salon_list_time.dart';

class ServiceSalonsScreen extends StatelessWidget {
  final String serviceName;

  const ServiceSalonsScreen({
    Key? key,
    required this.serviceName,
  }) : super(key: key);

  Future<double> _fetchSalonRating(String salonId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('review')
          .where('salonId', isEqualTo: salonId)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        return 0.0;
      }
      
      double totalRating = 0;
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final rating = (data['rating'] ?? 0).toDouble();
        totalRating += rating;
      }
      
      return totalRating / querySnapshot.docs.length;
    } catch (e) {
      print('Error calculating average rating for salon $salonId: $e');
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Salons offering $serviceName',
          style: GoogleFonts.montserrat(),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('approved_saloon')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Something went wrong',
                style: GoogleFonts.montserrat(),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allSalons = snapshot.data?.docs ?? [];
          final filteredSalons = allSalons.where((doc) {
            final salonData = doc.data() as Map<String, dynamic>;
            final services = salonData['services'];
            
            if (services is Map<String, dynamic>) {
              return services.values.any((service) => 
                service is Map<String, dynamic> &&
                service['serviceName'] == serviceName &&
                service['isEnabled'] == true
              );
            } else if (services is List<dynamic>) {
              return services.any((service) => 
                service is Map<String, dynamic> &&
                service['serviceName'] == serviceName &&
                service['isEnabled'] == true
              );
            }
            
            return false; 
          }).toList();

          if (filteredSalons.isEmpty) {
            return Center(
              child: Text(
                'No salons found offering $serviceName',
                style: GoogleFonts.montserrat(),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredSalons.length,
            itemBuilder: (context, index) {
              final salonData = filteredSalons[index].data() as Map<String, dynamic>;
              final salonId = filteredSalons[index].id;
              
              return FutureBuilder<double>(
                future: _fetchSalonRating(salonId),
                builder: (context, ratingSnapshot) {
                  final rating = ratingSnapshot.data ?? 0.0;
                  
                  final salon = Salon(
                    id: salonId,
                    name: salonData['saloonName'] ?? '',
                    address: salonData['location'] ?? '',
                    rating: rating,
                    imageUrl: salonData['shopUrl'] ?? '', 
                  );

                  return SalonListItem(salon: salon);
                },
              );
            },
          );
        },
      ),
    );
  }
}