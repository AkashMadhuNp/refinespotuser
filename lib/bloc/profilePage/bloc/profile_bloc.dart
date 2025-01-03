import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sec_pro/service/auth/auth_service.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthServices _authServices =AuthServices();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  ProfileBloc() : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<LogoutRequested>(_onLogoutRequested);
    
  }

  Future<void> _onLoadProfile(LoadProfile event,Emitter<ProfileState> emit)async{
    emit(ProfileLoading());
    try{

      final User? currentUser = _authServices.currentUser;
      if(currentUser != null){
        final DocumentSnapshot userDoc = await _firestore.collection("users").doc(currentUser.uid).get();
        final userData = userDoc.data() as Map<String,dynamic>?;
        if(userData != null){
          emit(ProfileLoaded(userData: userData));
        }else{
          emit(ProfileError(message: "User data not found"));
        }
      }else{
        emit(ProfileError(message: "User not authenticated"));
      }

    }catch(e){
      emit(ProfileError(message: e.toString()));

    }
  }


  Future<void> _onLogoutRequested(LogoutRequested event,Emitter<ProfileState> emit)async{
    try{
      await _authServices.signOut();
      emit(ProfileInitial());
    }catch(e){
      emit(ProfileError(message: "logout failed ${e.toString()}"));

    }
  }
}
