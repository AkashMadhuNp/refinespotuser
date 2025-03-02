import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:sec_pro/model/homePageService/home_service.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _favoritesSubscription;

  HomeBloc() : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<LoadServices>(_onLoadServices);
    on<UpdateUserData>(_onUpdateUserData);
    on<FavoritesUpdated>(_onFavoritesUpdated);
  }

  @override
  Future<void> close() {
    _favoritesSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadHomeData(LoadHomeData event, Emitter<HomeState> emit) async {
    try {
      emit(HomeLoading());

      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        emit(HomeError('User not authenticated'));
        return;
      }

      // Print user ID for debugging
      print('Current user ID: ${currentUser.uid}');
      
      final userData = await _fetchUserData(currentUser.uid);
      final services = await _fetchServices();

      // Initial load of favorites
      final initialFavorites = await _fetchFavorites(currentUser.uid);
      
      // Set up real-time favorites listener
      _setupFavoritesListener(currentUser.uid, emit);

      emit(HomeLoaded(
        userName: userData['name'] ?? currentUser.email?.split('@')[0] ?? 'User',
        email: currentUser.email ?? '',
        phoneNumber: userData['phone']?.toString() ?? 'N/A',
        services: services,
        favorites: initialFavorites,
      ));
    } catch (e) {
      print('Error in LoadHomeData: $e');
      emit(HomeError('Failed to load data: ${e.toString()}'));
    }
  }

  // Fetch favorites directly from the correct path
  Future<List<DocumentSnapshot>> _fetchFavorites(String userId) async {
    try {
      print('Fetching favorites for user ID: $userId');
      
      // Get the favorites collection document for the user
      final userFavoritesCollection = _firestore.collection('favorites').doc(userId);
      
      // Check if the document exists first
      final docSnapshot = await userFavoritesCollection.get();
      if (!docSnapshot.exists) {
        print('No favorites document exists for this user');
        return [];
      }
      
      // Get all documents in the userFavorites subcollection
      final snapshot = await userFavoritesCollection.collection('userFavorites').get();
      
      print('Found ${snapshot.docs.length} favorite salons');
      
      // Debug print each favorite's data
      for (var doc in snapshot.docs) {
        print('Favorite salon ID: ${doc.id}');
        print('Salon data: ${doc.data()}');
      }
      
      return snapshot.docs;
    } catch (e) {
      print('Error fetching favorites: $e');
      return [];
    }
  }

  void _setupFavoritesListener(String userId, Emitter<HomeState> emit) {
    // Cancel existing subscription if any
    _favoritesSubscription?.cancel();

    // Set up new subscription to the correct path
    _favoritesSubscription = _firestore
        .collection('favorites')
        .doc(userId)
        .collection('userFavorites')
        .snapshots()
        .listen(
      (snapshot) {
        print('Favorites listener triggered: ${snapshot.docs.length} items');
        add(FavoritesUpdated(snapshot.docs));
      },
      onError: (error) {
        print('Favorites listener error: $error');
      },
    );
  }

  Future<void> _onFavoritesUpdated(
    FavoritesUpdated event, 
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      
      print('Favorites updated event: ${event.favorites.length} items');
      
      emit(HomeLoaded(
        userName: currentState.userName,
        email: currentState.email,
        phoneNumber: currentState.phoneNumber,
        services: currentState.services,
        favorites: event.favorites,
      ));
    }
  }

  Future<Map<String, dynamic>> _fetchUserData(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      return userDoc.exists ? userDoc.data() ?? {} : {};
    } catch (e) {
      print('Error fetching user data: $e');
      return {};
    }
  }

  Future<List<HomeService>> _fetchServices() async {
    try {
      final snapshot = await _firestore.collection('services').get();
      return snapshot.docs
          .map((doc) => HomeService.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching services: $e');
      return [];
    }
  }

  Future<void> _onLoadServices(LoadServices event, Emitter<HomeState> emit) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final services = await _fetchServices();
      emit(HomeLoaded(
        userName: currentState.userName,
        email: currentState.email,
        phoneNumber: currentState.phoneNumber,
        services: services,
        favorites: currentState.favorites,
      ));
    }
  }

  Future<void> _onUpdateUserData(UpdateUserData event, Emitter<HomeState> emit) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(HomeLoaded(
        userName: event.userName,
        email: event.email,
        phoneNumber: event.phone,
        services: currentState.services,
        favorites: currentState.favorites,
      ));
    }
  }
}