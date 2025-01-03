import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sec_pro/service/auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final AuthServices _authServices;

  SignUpBloc({required AuthServices authServices})
      : _authServices = authServices,
        super(SignUpInitial()) {
    on<SignUpSubmitted>(_onSignUpSubmitted);
  }

  Future<void> _onSignUpSubmitted(
    SignUpSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    emit(SignUpLoading());

    try {
      final result = await _authServices.signUpUser(
        email: event.email,
        password: event.password,
        username: event.username,
        phone: int.parse(event.phone),
      );

      if (result != "success") {
        throw Exception(result);
      }

      // Initialize SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      
      // Store user data
      await Future.wait([
        prefs.setString('userEmail', event.email.trim()),
        prefs.setString('userPassword', event.password),
        prefs.setString('userName', event.username.trim()),
        prefs.setString('userPhone', event.phone.trim()),
        prefs.setBool('isLoggedIn', true),
      ]);

      emit(SignUpSuccess());
    } catch (e) {
      emit(SignUpFailure(e.toString(), error: ''));
    }
  }
}
