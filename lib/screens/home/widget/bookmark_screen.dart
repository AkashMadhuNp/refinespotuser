import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sec_pro/screens/home/bloc/bloc/home_bloc.dart';
import 'package:sec_pro/screens/home/bloc/bloc/home_event.dart';
import 'package:sec_pro/screens/home/bloc/bloc/home_state.dart';
import 'package:sec_pro/screens/home/widget/empty_favorites.dart';
import 'package:sec_pro/screens/home/widget/favorite_salon_card.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              Expanded(
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
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
                      return _buildFavoritesList(state);
                    }

                    return const Center(child: Text('Something went wrong'));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios),
          ),
          const SizedBox(width: 8),
          Text(
            "Bookmarks",
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(HomeLoaded state) {
    if (state.favorites.isEmpty) {
      return const EmptyFavorites();
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Implement refresh logic if needed
      },
      child: ListView.builder(
        itemCount: state.favorites.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final salon = state.favorites[index].data() as Map<String, dynamic>;
          if (!salon.containsKey('salonId')) {
            salon['salonId'] = state.favorites[index].id;
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: FavoriteSalonCard(salon: salon),
          );
        },
      ),
    );
  }
}