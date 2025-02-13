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

      final userData = await _fetchUserData(currentUser.uid);
      final services = await _fetchServices();

      // Set up real-time favorites listener
      _setupFavoritesListener(currentUser.uid, emit);

      // Initial state with empty favorites (will be updated by stream)
      emit(HomeLoaded(
        userName: userData['name'] ?? currentUser.email?.split('@')[0] ?? 'User',
        email: currentUser.email ?? '',
        phoneNumber: userData['phone']?.toString() ?? 'N/A',
        services: services,
        favorites: [],
      ));
    } catch (e) {
      emit(HomeError('Failed to load data: ${e.toString()}'));
    }
  }

  void _setupFavoritesListener(String userId, Emitter<HomeState> emit) {
    // Cancel existing subscription if any
    _favoritesSubscription?.cancel();

    // Set up new subscription
    _favoritesSubscription = _firestore
        .collection('favorites')
        .doc(userId)
        .collection('userFavorites')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        add(FavoritesUpdated(snapshot.docs));
      },
      onError: (error) {
        emit(HomeError('Failed to load favorites: $error'));
      },
    );
  }

  Future<void> _onFavoritesUpdated(
    FavoritesUpdated event, 
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
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