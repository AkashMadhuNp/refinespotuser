// part of 'home_bloc.dart';

// sealed class HomeState extends Equatable {
//   const HomeState();
  
//   @override
//   List<Object> get props => [];
// }

// final class HomeInitial extends HomeState {}


// class HomeLoading extends HomeState {}

// class HomeLoaded extends HomeState {
//   final String userName;
//   final String email;
//   final String phoneNumber;
//   final List<HomeService> services;
//   final List<DocumentSnapshot> favorites;

//   HomeLoaded({
//     required this.userName,
//     required this.email,
//     required this.phoneNumber,
//     required this.services,
//     required this.favorites,
//   });
// }

// class HomeError extends HomeState {
//   final String message;
//   HomeError(this.message);
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sec_pro/model/homePageService/home_service.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final String userName;
  final String email;
  final String phoneNumber;
  final List<HomeService> services;
  final List<DocumentSnapshot> favorites;

  HomeLoaded({
    required this.userName,
    required this.email,
    required this.phoneNumber,
    required this.services,
    required this.favorites,
  });
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}