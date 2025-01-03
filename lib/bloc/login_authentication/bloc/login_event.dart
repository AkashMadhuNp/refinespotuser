import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class EmailLoginRequested extends LoginEvent {
  final String email;
  final String password;

  const EmailLoginRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class GoogleLoginRequested extends LoginEvent {
  final BuildContext context;

  const GoogleLoginRequested(this.context);

  @override
  List<Object?> get props => [context];
}
