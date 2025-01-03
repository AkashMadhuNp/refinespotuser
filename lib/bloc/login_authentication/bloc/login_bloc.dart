import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sec_pro/bloc/login_authentication/bloc/login_event.dart';
import 'package:sec_pro/bloc/login_authentication/bloc/login_state.dart';
import 'package:sec_pro/service/auth/auth_service.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthServices _authServices;
  
  LoginBloc({required AuthServices authServices})
      : _authServices = authServices,
        super(LoginInitial()) {
    on<EmailLoginRequested>(_onEmailLoginRequested);
    on<GoogleLoginRequested>(_onGoogleLoginRequested);
  }

  Future<void> _onEmailLoginRequested(
    EmailLoginRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      final user = await _authServices.loginUserWithEmailAndPassword(
        event.email,
        event.password,
      );
      if (user != null) {
        emit(LoginSuccess(user));
      } else {
        emit(const LoginFailure('Login failed'));
      }
    } on AuthException catch (e) {
      emit(LoginFailure(e.message));
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> _onGoogleLoginRequested(
    GoogleLoginRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      final user = await _authServices.signInWithGoogle(event.context);
      if (user != null) {
        emit(LoginSuccess(user));
      } else {
        emit(const LoginFailure('Google sign in cancelled'));
      }
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

}
