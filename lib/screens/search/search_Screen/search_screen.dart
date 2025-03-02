import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sec_pro/screens/search/saloon_Detail/sample.dart';
import 'package:sec_pro/screens/search/search_Screen/bloc/search_bloc.dart';
import 'package:sec_pro/screens/search/search_Screen/bloc/search_event.dart';
import 'package:sec_pro/screens/search/search_Screen/bloc/search_state.dart';
import 'package:sec_pro/screens/search/search_Screen/widgets/empty_result.dart';
import 'package:sec_pro/screens/search/search_Screen/widgets/price_range.dart';
import 'package:sec_pro/screens/search/search_Screen/widgets/salon_list_item.dart';
import 'package:sec_pro/screens/search/search_Screen/widgets/search_bar.dart';
import 'package:sec_pro/screens/search/search_Screen/widgets/service_filter.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc()..add(FetchServicesEvent()),
      child: SearchScreenView(),
    );
  }
}

class SearchScreenView extends StatefulWidget {
  const SearchScreenView({super.key});

  @override
  State<SearchScreenView> createState() => _SearchScreenViewState();
}

class _SearchScreenViewState extends State<SearchScreenView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToSalonDetails(Map<String, dynamic> salonData) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SampleDetail(
          salonData: salonData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // Search Bar Widget
                  SearchBarWidget(
                    controller: _searchController,
                    onChanged: (value) => context.read<SearchBloc>().add(SearchQueryChanged(value)),
                    showFilters: state.showFilters,
                    onFilterToggle: () => context.read<SearchBloc>().add(ToggleFiltersEvent()),
                  ),
                  
                  if (state.showFilters) ...[
                    const SizedBox(height: 20),
                    
                    // Service Filter Widget
                    ServiceFilterWidget(
                      isLoading: state.isLoadingServices,
                      availableServices: state.availableServices,
                      selectedService: state.selectedService,
                      onServiceChanged: (service) => 
                          context.read<SearchBloc>().add(ServiceFilterChanged(service)),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Price Range Widget
                    PriceRangeWidget(
                      currentRangeValues: state.priceRange,
                      minPrice: state.minPrice,
                      maxPrice: state.maxPrice,
                      onRangeChanged: (values) => context.read<SearchBloc>()
                          .add(PriceRangeChanged(values.start, values.end)),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Reset Filters Button
                    Center(
                      child: TextButton.icon(
                        onPressed: () => context.read<SearchBloc>().add(ResetFiltersEvent()),
                        icon: Icon(Icons.refresh, size: 18),
                        label: Text(
                          'Reset Filters',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 20),
                  
                  // Salon List
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: context.read<SearchBloc>().getSalonsStream(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(child: Text('Something went wrong'));
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final bloc = context.read<SearchBloc>();
                        var salons = snapshot.data!.docs.where((doc) {
                          final salonData = doc.data() as Map<String, dynamic>;
                          return bloc.salonMatchesFilters(salonData);
                        }).toList();

                        if (salons.isEmpty) {
                          return EmptyResultsWidget(
                            showFilters: state.showFilters,
                            onResetFilters: () {
                              context.read<SearchBloc>().add(ResetAllFiltersEvent());
                              _searchController.clear();
                            },
                          );
                        }

                        return ListView.builder(
                          itemCount: salons.length,
                          itemBuilder: (context, index) {
                            final salonDoc = salons[index];
                            final salonData = bloc.convertSalonData(salonDoc);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: SalonListItem(
                                salonData: salonData,
                                onTap: () => _navigateToSalonDetails(salonData),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
