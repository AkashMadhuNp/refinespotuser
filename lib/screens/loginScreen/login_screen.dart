import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:sec_pro/bloc/login_authentication/bloc/login_bloc.dart';
import 'package:sec_pro/bloc/login_authentication/bloc/login_event.dart';
import 'package:sec_pro/bloc/login_authentication/bloc/login_state.dart';
import 'package:sec_pro/screens/forgetPassword/forget_password.dart';
import 'package:sec_pro/screens/home/widget/home_nav_bar.dart';
import 'package:sec_pro/screens/loginScreen/widget/custom_text_form_field.dart';
import 'package:sec_pro/screens/signUpScreen/signup_screen.dart';
import 'package:sec_pro/service/auth/auth_service.dart';
import 'package:sec_pro/service/validation/validation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

 

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(authServices: AuthServices()),
      child: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const BottomNavigatorBar(),
              ),
              (route) => false,
            );
          } else if (state is LoginFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Lottie.asset(
                          "asset/Login.json",
                          height: 300,
                          repeat: true,
                          reverse: true,
                        ),
                       ),
                      Text(
                        "LOGIN",
                        style: GoogleFonts.montserrat(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      GestureDetector(
                        onTap: state is LoginLoading
                            ? null
                            : () {
                                context
                                    .read<LoginBloc>()
                                    .add(GoogleLoginRequested(context));
                              },
                        child: Container(
                          height: 60,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.grey.shade100,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Lottie.asset(
                                "asset/google.json",
                                height: 60,
                                width: 60,
                              ),
                              Text(
                                "Sign in with Google",
                                style: GoogleFonts.montserrat(),
                              )
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: const Divider(thickness: 3),
                          ),
                          const Text("OR"),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: const Divider(thickness: 3),
                          ),
                        ],
                      ),
                      CustomTextField(
                        controller: _emailController,
                        validator: FormValidators.validateEmail,
                        hint: "Email",
                        prefixIcon: Icons.email,
                      ),
                      CustomTextField(
                        controller: _passwordController,
                        validator: FormValidators.validatePassword,
                        hint: "Password",
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        prefixIcon: Icons.lock_outline,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ForgetAccountPage(),
                            ));
                          },
                          child: Text(
                            "Forget Password?",
                            style: GoogleFonts.montserrat(
                              color: const Color.fromRGBO(0, 76, 255, 1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: state is LoginLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<LoginBloc>().add(
                                          EmailLoginRequested(
                                            _emailController.text.trim(),
                                            _passwordController.text,
                                          ),
                                        );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(0, 76, 255, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: state is LoginLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Login',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: GoogleFonts.montserrat(
                                color: Colors.black54,
                              ),
                            ),
                            TextButton(
                              onPressed: state is LoginLoading
                                  ? null
                                  : () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SignUpScreen(),
                                        ),
                                      );
                                    },
                              child: Text(
                                "Sign Up",
                                style: GoogleFonts.montserrat(
                                  color: const Color.fromRGBO(0, 76, 255, 1),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}