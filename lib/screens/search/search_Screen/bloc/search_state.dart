import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SearchState extends Equatable {
  final String searchQuery;
  final bool showFilters;
  final String? selectedService;
  final RangeValues priceRange;
  final List<String> availableServices;
  final bool isLoadingServices;
  final double minPrice;
  final double maxPrice;

  const SearchState({
    this.searchQuery = '',
    this.showFilters = false,
    this.selectedService,
    required this.priceRange,
    this.availableServices = const [],
    this.isLoadingServices = false,
    this.minPrice = 0,
    this.maxPrice = 5000,
  });

  SearchState copyWith({
    String? searchQuery,
    bool? showFilters,
    String? selectedService,
    RangeValues? priceRange,
    List<String>? availableServices,
    bool? isLoadingServices,
    double? minPrice,
    double? maxPrice,
  }) {
    return SearchState(
      searchQuery: searchQuery ?? this.searchQuery,
      showFilters: showFilters ?? this.showFilters,
      selectedService: selectedService ?? this.selectedService,
      priceRange: priceRange ?? this.priceRange,
      availableServices: availableServices ?? this.availableServices,
      isLoadingServices: isLoadingServices ?? this.isLoadingServices,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }

  @override
  List<Object?> get props => [
        searchQuery,
        showFilters,
        selectedService,
        priceRange,
        availableServices,
        isLoadingServices,
        minPrice,
        maxPrice,
      ];
}
