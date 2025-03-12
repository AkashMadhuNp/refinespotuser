import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sec_pro/bloc/signUpAuthentication/bloc/sign_up_bloc.dart';
import 'package:sec_pro/constant/constant.dart';
import 'package:sec_pro/screens/loginScreen/widget/custom_text_form_field.dart';
import 'package:sec_pro/screens/signUpScreen/widgets/sign_up_btn.dart';
import 'package:sec_pro/screens/signUpScreen/widgets/sign_up_header.dart';
import 'package:sec_pro/service/validation/validation.dart';

class SignUpForm extends StatefulWidget {
  final Function onSignUpSuccess;
  
  const SignUpForm({
    Key? key,
    required this.onSignUpSuccess,
  }) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
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
          backgroundColor: AppColors.error,
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
    return BlocListener<SignUpBloc, SignUpState>(
      listener: (context, state) {
        if (state is SignUpSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Account created Successfully!"),
              backgroundColor: AppColors.success,
            ),
          );
          widget.onSignUpSuccess();
        } else if (state is SignUpFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: ${state.error}"),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SignUpHeader(),
              
              const Divider(thickness: 3),
              
              CustomTextField(
                controller: _emailController,
                validator: FormValidators.validateEmail,
                hint: 'Enter your email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              
              SizedBox(height: AppSizes.spacingXLarge),
              
              CustomTextField(
                controller: _usernameController,
                validator: FormValidators.validateUsername,
                hint: 'Choose a username',
                prefixIcon: Icons.person_outline,
              ),
              
              SizedBox(height: AppSizes.spacingXLarge),
              
              CustomTextField(
                controller: _passwordController,
                validator: FormValidators.validatePassword,
                hint: 'Create a strong password',
                prefixIcon: Icons.lock_outline,
                obscureText: !_isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),
              
              SizedBox(height: AppSizes.spacingXLarge),
              
              CustomTextField(
                controller: _confirmPasswordController,
                validator: (value) => FormValidators.validateConfirmPassword(value, _passwordController.text),
                hint: 'Confirm your password',
                prefixIcon: Icons.lock_outline,
                obscureText: !_isConfirmPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                ),
              ),
              
              SizedBox(height: AppSizes.spacingXLarge),
              
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
              
              SizedBox(height: AppSizes.spacingXLarge),
              
              SignUpButton(onPressed: _handleSignUp),
            ],
          ),
        ),
      ),
    );
  }
}