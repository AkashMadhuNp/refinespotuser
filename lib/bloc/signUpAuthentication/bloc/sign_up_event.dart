part of 'sign_up_bloc.dart';

sealed class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object> get props => [];
}


class SignUpSubmitted extends SignUpEvent {
  final String email;
  final String password;
  final String username;
  final String phone;

  SignUpSubmitted({
    required this.email, 
    required this.password, 
    required this.username, 
    required this.phone
    });

  List<Object> get props =>[email,password,username,phone];
}