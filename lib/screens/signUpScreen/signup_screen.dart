import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:sec_pro/bloc/signUpAuthentication/bloc/sign_up_bloc.dart';
import 'package:sec_pro/screens/home/widget/home_nav_bar.dart';
import 'package:sec_pro/screens/loginScreen/widget/custom_text_form_field.dart';
import 'package:sec_pro/service/validation/validation.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;



void _handleSignUp() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please check all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<SignUpBloc>().add(
          SignUpSubmitted(
            email: _emailController.text,
            password: _passwordController.text,
            username: _usernameController.text,
            phone: _phoneController.text,
          ),
        );
  }


   @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }


  


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BlocListener<SignUpBloc,SignUpState>(
          listener: (context, state) {
            if(state is SignUpSuccess){
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Account created Successfully!"),
                backgroundColor: Colors.green,
                )

              );
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) =>const BottomNavigatorBar(),)
              );
            }else if(state is SignUpFailure){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Error: ${state.error}"),
                  backgroundColor: Colors.red,
                ),
              );

              
              
            }
          },
          child: SingleChildScrollView(
            child: Form(
               key: _formKey,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0,right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 60.0),
                      child: SizedBox(
                        height: 200,
                        child: Row(
                          children: [
                            Text("CREATE \nACCOUNT",style: GoogleFonts.montserrat(
                              fontSize: 30,
                              color: Colors.grey
                            ),),
              
                            Lottie.asset(
                          "asset/Login.json",
                          height: 300,
                          repeat: true,
                          reverse: true
                          ),
                          ],
                        ),
                      ),
                    ),
              
              
                   const Divider(thickness: 3,),
              
              
                        CustomTextField(
                          controller: _emailController,
                          validator: FormValidators.validateEmail,  // Just pass the function reference
                          hint: 'Enter your email',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
            
                                    
                            const SizedBox(height: 15,),
              
              
                             CustomTextField(
                                      controller: _usernameController,
                                      validator: FormValidators.validateUsername,
                                      hint: 'Choose a username',
                                      prefixIcon: Icons.person_outline,
                                    ),
            
              
                           const SizedBox(height: 15,),
              
                            CustomTextField(
                                  controller: _passwordController,
                                  validator: FormValidators.validatePassword,
                                  hint: 'Create a strong password',
                                  prefixIcon: Icons.lock_outline,
                                  obscureText: !_isPasswordVisible,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                  ),
                                ),
            
              
                            const SizedBox(height: 15,),  
              
              
                            CustomTextField(
                                controller: _confirmPasswordController,
                                // For confirm password, we need to create a closure to pass the password
                                validator: (value) => FormValidators.validateConfirmPassword(value, _passwordController.text),
                                hint: 'Confirm your password',
                                prefixIcon: Icons.lock_outline,
                                obscureText: !_isConfirmPasswordVisible,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                                ),
                              ),
                                          
                             const  SizedBox(height: 15,),
                           
            
                           CustomTextField(
                                controller: _phoneController,
                                validator: FormValidators.validatePhone,
                                hint: 'Enter your phone number',
                                prefixIcon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                              ),
            
            
                                const  SizedBox(height: 15,),
            
            
                            SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: BlocBuilder<SignUpBloc,SignUpState>(
                              builder: (context, state) {
                                return ElevatedButton(
                                onPressed:  _handleSignUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(0, 76, 255, 1),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: state is SignUpLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Register',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          );
            
                                
                              },
                              
                            ),
                          ),
              
              
                  ],
                ),
              ),
            ),
          ),
        ),
      
      
      ),
    );
  }
}