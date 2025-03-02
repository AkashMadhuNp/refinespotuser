import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sec_pro/screens/search/search_Screen/bloc/search_event.dart';
import 'package:sec_pro/screens/search/search_Screen/bloc/search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final FirebaseFirestore _firestore;

  SearchBloc({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(SearchState(priceRange: RangeValues(0, 5000))) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<ToggleFiltersEvent>(_onToggleFilters);
    on<ServiceFilterChanged>(_onServiceFilterChanged);
    on<PriceRangeChanged>(_onPriceRangeChanged);
    on<ResetFiltersEvent>(_onResetFilters);
    on<ResetAllFiltersEvent>(_onResetAllFilters);
    on<FetchServicesEvent>(_onFetchServices);
  }

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query.toLowerCase()));
  }

  void _onToggleFilters(
    ToggleFiltersEvent event,
    Emitter<SearchState> emit,
  ) {
    emit(state.copyWith(showFilters: !state.showFilters));
  }

  void _onServiceFilterChanged(
    ServiceFilterChanged event,
    Emitter<SearchState> emit,
  ) {
    emit(state.copyWith(selectedService: event.service));
  }

  void _onPriceRangeChanged(
    PriceRangeChanged event,
    Emitter<SearchState> emit,
  ) {
    emit(state.copyWith(
      priceRange: RangeValues(event.start, event.end),
    ));
  }

  void _onResetFilters(
    ResetFiltersEvent event,
    Emitter<SearchState> emit,
  ) {
    emit(state.copyWith(
      selectedService: null,
      priceRange: RangeValues(state.minPrice, state.maxPrice),
    ));
  }

  void _onResetAllFilters(
    ResetAllFiltersEvent event,
    Emitter<SearchState> emit,
  ) {
    emit(state.copyWith(
      selectedService: null,
      priceRange: RangeValues(state.minPrice, state.maxPrice),
      searchQuery: '',
    ));
  }

  Future<void> _onFetchServices(
    FetchServicesEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(isLoadingServices: true));

    try {
      final snapshot = await _firestore.collection('services').get();

      final List<String> servicesList = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['name'] != null) {
          servicesList.add(data['name'] as String);
        }
      }
      
      servicesList.sort();
      
      emit(state.copyWith(
        availableServices: servicesList,
        isLoadingServices: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingServices: false));
      print('Error fetching services: $e');
    }
  }

  // Helper method to get salons stream
  Stream<QuerySnapshot> getSalonsStream() {
    return _firestore.collection('approved_saloon').snapshots();
  }
  
  // Helper method to convert salon data
  Map<String, dynamic> convertSalonData(DocumentSnapshot doc) {
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

  // Method to check if a salon matches the filters
  bool salonMatchesFilters(Map<String, dynamic> salonData) {
    final name = salonData['saloonName']?.toString().toLowerCase() ?? '';
    final location = salonData['location']?.toString().toLowerCase() ?? '';
    final services = salonData['services'];
    
    // Check if search query matches name or location
    bool matchesSearch = name.contains(state.searchQuery) || 
                        location.contains(state.searchQuery);
    
    // Check service type
    bool matchesServiceType = true;
    if (state.selectedService != null) {
      matchesServiceType = false;
      
      if (services is List<dynamic>) {
        matchesServiceType = services.any((service) => 
          service is Map<String, dynamic> && 
          service['serviceName'] == state.selectedService
        );
      } else if (services is Map<String, dynamic>) {
        matchesServiceType = services.values.any((service) => 
          service is Map<String, dynamic> && 
          service['serviceName'] == state.selectedService
        );
      }
    }
    
    // Check price range
    bool priceInRange = false;
    
    if (services is List<dynamic>) {
      priceInRange = services.any((service) {
        if (service is Map<String, dynamic> && service['price'] != null) {
          final price = double.tryParse(service['price'].toString()) ?? 0;
          return price >= state.priceRange.start && 
                price <= state.priceRange.end;
        }
        return false;
      });
    } else if (services is Map<String, dynamic>) {
      priceInRange = services.values.any((service) {
        if (service is Map<String, dynamic> && service['price'] != null) {
          final price = double.tryParse(service['price'].toString()) ?? 0;
          return price >= state.priceRange.start && 
                price <= state.priceRange.end;
        }
        return false;
      });
    }

    return matchesSearch && matchesServiceType && priceInRange;
  }
}
