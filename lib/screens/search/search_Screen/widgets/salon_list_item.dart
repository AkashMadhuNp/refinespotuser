import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SalonListItem extends StatelessWidget {
  final Map<String, dynamic> salonData;
  final VoidCallback onTap;

  const SalonListItem({
    Key? key,
    required this.salonData,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Salon Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                salonData['shopUrl'],
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.broken_image,
                  size: 100,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
            const SizedBox(width: 15),

            // Salon Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    salonData['name'],
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          salonData['location'],
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.design_services,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 5),
                      _buildServicesList(salonData['services']),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build services text
  Widget _buildServicesList(dynamic services) {
    List<String> serviceNames = [];
    
    if (services is List<dynamic>) {
      for (var service in services) {
        if (service is Map<String, dynamic> && service['serviceName'] != null) {
          serviceNames.add(service['serviceName'].toString());
        }
      }
    } else if (services is Map<String, dynamic>) {
      for (var service in services.values) {
        if (service is Map<String, dynamic> && service['serviceName'] != null) {
          serviceNames.add(service['serviceName'].toString());
        }
      }
    }
    
    return Expanded(
      child: Text(
        serviceNames.join(', '),
        style: GoogleFonts.montserrat(
          fontSize: 14,
          color: Colors.grey.shade700,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }
}