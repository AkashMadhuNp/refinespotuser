import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sec_pro/screens/search/saloon_Detail/sample.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  double _minPrice = 0;
  double _maxPrice = 5000;
  RangeValues _currentRangeValues = RangeValues(0, 5000);
  bool _showFilters = false;
  
  Stream<QuerySnapshot> _getSalonsStream() {
    return FirebaseFirestore.instance
        .collection('approved_saloon')
        .snapshots();
  }

  Map<String, dynamic> _convertSalonData(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Handle working hours with sub-fields
    Map<String, dynamic> workingHours;
    if (data['workingHours'] != null && 
        data['workingHours']['opening'] != null && 
        data['workingHours']['closing'] != null) {
      workingHours = {
        'opening': data['workingHours']['opening'],
        'closing': data['workingHours']['closing']
      };
    } else {
      workingHours = {
        'opening': '9:00 AM',
        'closing': '6:00 PM'
      };
    }

    // Handle coordinates
    final coordinates = data['coordinates'] as Map<String, dynamic>;

    return {
      'id': doc.id,
      'name': data['saloonName'] ?? 'Unknown',
      'location': data['location'] ?? 'Unknown location',
      'shopUrl': data['shopUrl'] ?? '',
      'profileUrl': data['profileUrl'] ?? '',
      'licenseUrl': data['licenseUrl'] ?? '',
      'services': data['services'] ?? [],
      'workingHours': workingHours,  
      'phone': data['phone'] ?? '',
      'email': data['email'] ?? '',
      'holidays': data['holidays'] ?? [],
      'coordinates': {
        'latitude': coordinates['latitude'] ?? 0.0,
        'longitude': coordinates['longitude'] ?? 0.0,
      },
      'status': data['status'] ?? '',
    };
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
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
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
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
                                color: _showFilters ? Colors.blue : Colors.grey.shade600,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showFilters = !_showFilters;
                                });
                              },
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
              ),
              if (_showFilters) ...[
                const SizedBox(height: 20),
                Text(
                  'Price Range',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                RangeSlider(
                  values: _currentRangeValues,
                  min: _minPrice,
                  max: _maxPrice,
                  divisions: 50,
                  labels: RangeLabels(
                    '₹${_currentRangeValues.start.round()}',
                    '₹${_currentRangeValues.end.round()}',
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _currentRangeValues = values;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${_currentRangeValues.start.round()}',
                      style: GoogleFonts.montserrat(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '₹${_currentRangeValues.end.round()}',
                      style: GoogleFonts.montserrat(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _getSalonsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Something went wrong'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var salons = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = data['saloonName']?.toString().toLowerCase() ?? '';
                      final location = data['location']?.toString().toLowerCase() ?? '';
                      final services = (data['services'] as List<dynamic>?) ?? [];
                      
                      // Check if any service price is within the selected range
                      bool priceInRange = services.any((service) {
                        final price = double.tryParse(service['price'].toString()) ?? 0;
                        return price >= _currentRangeValues.start && 
                               price <= _currentRangeValues.end;
                      });

                      return (name.contains(_searchQuery) || 
                             location.contains(_searchQuery)) &&
                             priceInRange;
                    }).toList();

                    if (salons.isEmpty) {
                      return Center(
                        child: Text(
                          'No salons found',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: salons.length,
                      itemBuilder: (context, index) {
                        final salonDoc = salons[index];
                        final salonData = _convertSalonData(salonDoc);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => SampleDetail(
                                    salonData: salonData,
                                  ),
                                ),
                              );
                            },
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
                                            Expanded(
                                              child: Text(
                                                (salonData['services'] as List<dynamic>)
                                                    .map((service) => service['serviceName'].toString())
                                                    .join(', '),
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade700,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}