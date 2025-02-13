import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:sec_pro/bloc/login_authentication/bloc/login_bloc.dart';
import 'package:sec_pro/bloc/profilePage/bloc/profile_bloc.dart';
import 'package:sec_pro/bloc/signUpAuthentication/bloc/sign_up_bloc.dart';
import 'package:sec_pro/screens/home/bloc/bloc/home_bloc.dart';
import 'package:sec_pro/screens/search/payment/key.dart';
import 'package:sec_pro/screens/splashScreen/splash_screen.dart';
import 'package:sec_pro/service/auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


//stripe payment gateway

class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('${bloc.runtimeType} $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('${bloc.runtimeType} $error $stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SharedPreferences.getInstance();
  Stripe.publishableKey = STRIPE_PUBLISH_KEY;
  await Stripe.instance.applySettings();
  
  Bloc.observer = SimpleBlocObserver();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    final authServices = AuthServices();

    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc(
            authServices: authServices,
          ),
        ),
        BlocProvider<SignUpBloc>(
          create: (context) => SignUpBloc(
            authServices: authServices,
          ),
        ),


        BlocProvider<HomeBloc>(create: (context) => HomeBloc(),),

        BlocProvider<ProfileBloc>(
          create: (context) => ProfileBloc(),
          )
      ],
      child: MaterialApp(
        title: 'REFINE SPOT',
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),
    );
  }
}