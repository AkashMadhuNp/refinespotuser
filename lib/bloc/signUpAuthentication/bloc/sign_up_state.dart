part of 'sign_up_bloc.dart';

sealed class SignUpState extends Equatable {
  const SignUpState();
  
  @override
  List<Object> get props => [];
}

final class SignUpInitial extends SignUpState {}

final class SignUpLoading extends SignUpState{}

final class SignUpSuccess extends SignUpState{}

final class SignUpFailure extends SignUpState{
  final String error;

  SignUpFailure(String string, {required this.error});

  @override
  List<Object> get props=>[error];
  
}
