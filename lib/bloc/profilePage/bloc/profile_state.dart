part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();
  
  @override
  List<Object> get props => [];
}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState{}

final class ProfileLoaded extends ProfileState{
  final Map<String,dynamic> userData;

  ProfileLoaded({required this.userData});

}

final class ProfileError extends ProfileState{
  final String message;

  ProfileError({required this.message});
}

