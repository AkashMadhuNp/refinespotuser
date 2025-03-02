import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sec_pro/screens/home/bloc/bloc/home_bloc.dart';
import 'package:sec_pro/screens/home/bloc/bloc/home_state.dart';
import 'package:sec_pro/screens/home/bloc/bloc/home_event.dart';
import 'package:sec_pro/screens/home/widget/empty_favorites.dart';
import 'package:sec_pro/screens/home/widget/home_drawer.dart';
import 'package:sec_pro/screens/home/widget/home_header.dart';
import 'package:sec_pro/screens/home/widget/services_grid.dart';
import 'package:sec_pro/screens/home/widget/favorite_salon_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(LoadHomeData());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return SafeArea(
          child: Scaffold(
            key: _scaffoldKey,
            drawer: _buildDrawer(state),
            body: _buildBody(state),
          ),
        );
      },
    );
  }

  Widget? _buildDrawer(HomeState state) {
    if (state is HomeLoaded) {
      return HomeDrawer(
        userName: state.userName,
        email: state.email,
        phoneNumber: state.phoneNumber,
      );
    }
    return null;
  }

  Widget _buildBody(HomeState state) {
    if (state is HomeLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is HomeError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<HomeBloc>().add(LoadHomeData());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is HomeLoaded) {
      return Padding(
        padding: const EdgeInsets.only(top: 10.0, right: 15, left: 15),
        child: Column(
          children: [
            HomeHeader(
              userName: state.userName,
              isLoading: false,
              onMenuPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<HomeBloc>().add(LoadHomeData());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ServicesGrid(services: state.services),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "Favorite Salons",
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFavorites(state.favorites),
                      const SizedBox(height: 200),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const Center(child: Text('Something went wrong'));
  }

// Update your FavoriteSalonCard to match the actual field structure in Firestore
Widget _buildFavorites(List<DocumentSnapshot> favorites) {
  if (favorites.isEmpty) {
    print('No favorites to display');
    return const EmptyFavorites();
  }

  print('Building favorites list with ${favorites.length} items');
  
  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: favorites.length,
    padding: const EdgeInsets.all(16),
    itemBuilder: (context, index) {
      final docData = favorites[index].data() as Map<String, dynamic>;
      
      // Create a consistent salon map that matches what's in Firestore
      final Map<String, dynamic> salon = {
        'salonId': favorites[index].id,
        'salonName': docData['salonName'] ?? 'Unknown Salon', // Use salonName consistently
        'location': docData['location'] ?? docData['address'] ?? 'Location not available',
        'phone': docData['phone'] ?? 'Not available',
        'shopUrl': docData['shopUrl'] ?? docData['profileUrl'] ?? '',
      };
      
      return FavoriteSalonCard(salon: salon);
    },
  );
}
}