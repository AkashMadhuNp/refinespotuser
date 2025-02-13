import 'package:cloud_firestore/cloud_firestore.dart';

abstract class HomeEvent {}

class LoadHomeData extends HomeEvent {}

class LoadServices extends HomeEvent {}

class UpdateUserData extends HomeEvent {
  final String userName;
  final String email;
  final String phone;

  UpdateUserData({
    required this.userName,
    required this.email,
    required this.phone,
  });
}

class FavoritesUpdated extends HomeEvent {
  final List<DocumentSnapshot> favorites;

  FavoritesUpdated(this.favorites);
}