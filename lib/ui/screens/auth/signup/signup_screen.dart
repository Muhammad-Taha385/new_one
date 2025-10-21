import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:real_time_chat_application/bloc/signup_bloc/signup_bloc.dart';
import 'package:real_time_chat_application/bloc/signup_bloc/signup_event.dart';
import 'package:real_time_chat_application/bloc/signup_bloc/signup_state.dart';
// import 'package:real_time_chat_application/bloc/text_field_bloc/text_field_bloc.dart';
import 'package:real_time_chat_application/core/constants/colors.dart';
import 'package:real_time_chat_application/core/constants/strings.dart';
import 'package:real_time_chat_application/core/constants/styles.dart';
// import 'package:real_time_chat_application/core/enums/enums.dart';
// import 'package:real_time_chat_application/core/services/signin_auth_service.dart';
import 'package:real_time_chat_application/ui/Widgets/TextField/CustomButton.dart';
import 'package:real_time_chat_application/ui/Widgets/TextField/custom_text.dart';
import 'package:real_time_chat_application/ui/Widgets/TextField/textfield.dart';
// import 'package:real_time_chat_application/ui/screens/auth/login/login_viewmodel.dart';
// import 'package:real_time_chat_application/core/utils/toastmessage_utils.dart';
// import 'package:real_time_chat_application/ui/screens/auth/signup/signup_viewmodel.dart';

/// SignupScreen allows users to register a new account with email and password.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool loading = false;

  // Validators
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your name";
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter an email";
    }
    RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return "Please enter a valid email";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a password";
    }
    if (value.length < 8) {
      return "Password must be at least 8 characters";
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please confirm your password";
    }
    if (value.length < 8) {
      return "Password must be at least 8 characters";
    }
    if (value != passwordController.text) {
      return "Passwords do not match";
    }
    return null;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  /// Handles the signup form submission and user registration.
  void submitForm() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      context.read<SignupBloc>().add(SignupAuth(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
            context: context,
            name: nameController.text.trim(),
          ));

      nameController.clear();
      passwordController.clear();
      emailController.clear();
      confirmPasswordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignupBloc, SignupState>(
      listener: (context, state) {
        if (state is SignupLoading) {
          loading = true;
        }
      },
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context)
              .unfocus(), // Dismiss keyboard on tap outside
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 80.h),
                          // Text("", style: h),
                          OnBoardingText(
                            text: "Sign up with Email",
                            color: primary,
                            fontFamily: "CarosBold",
                            fontWeight: FontWeight.bold,
                            fontSize: 30.sp,
                          ),
                          SizedBox(height: 20.h),
                          OnBoardingText(
                            text:
                                "Get chatting with friends and family today by",
                            color: grey,
                            fontFamily: "Circular-Std",
                            fontSize: 15.sp,
                            height: 1.5,
                          ),
                          OnBoardingText(
                            text: "signing up for our chat app!",
                            color: grey,
                            fontFamily: "Circular-Std",
                            fontSize: 15.sp,
                            height: 1.5,
                          ),

                          SizedBox(
                            height: 20.h,
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: CustomTextField(
                              labelText: "Your name",
                              controller: nameController,
                              validate: _validateName,
                              labelStyle: TextStyle(
                                  color: loginScreenLabelColor,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Circular-Std",
                                  fontSize: 14.sp),
                                                      border: const UnderlineInputBorder(),
                                enabledBorder: 
            const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1),
            ),
                        focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1),
            ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: CustomTextField(
                              labelText: "Your email",
                              controller: emailController,
                              validate: _validateEmail,
                              labelStyle: TextStyle(
                                  color: loginScreenLabelColor,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Circular-Std",
                                  fontSize: 14.sp),
                                                      border: const UnderlineInputBorder(),
                                enabledBorder: 
            const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1),
            ),
                        focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1),
            ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: CustomTextField(
                              labelText: "Password",
                              isObscure: true,
                              controller: passwordController,
                              validate: _validatePassword,
                              labelStyle: TextStyle(
                                color: loginScreenLabelColor,
                                fontWeight: FontWeight.w600,
                                fontFamily: "Circular-Std",
                                fontSize: 14.sp,
                              ),
                                                  border: const UnderlineInputBorder(),
                                enabledBorder: 
            const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1),
            ),
                        focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1),
            ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: CustomTextField(
                              labelText: "Confirm Password",
                              isObscure: true,
                              controller: confirmPasswordController,
                              validate: _validateConfirmPassword,
                              labelStyle: TextStyle(
                                  color: loginScreenLabelColor,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Circular-Std",
                                  fontSize: 14.sp),
                                                      border: const UnderlineInputBorder(),
                                enabledBorder: 
            const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1),
            ),
                        focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1),
            ),
                            ),
                          ),

                          SizedBox(height: 20.h),
                          ValueListenableBuilder<TextEditingValue>(
                            // first:emailController,
                            // second:passwordController,
                            // first:
                            valueListenable: nameController,
                            builder: (context, value, child) {
                              final hasText = value.text.trim().isNotEmpty;
                              return BlocBuilder<SignupBloc, SignupState>(
                                  builder: (context, state) {
                                final isloading = state is SignupLoading;
                                return CustomButtonWidget(
                                  fontSize: 15,
                                  backgroundColor: hasText
                                      ? loginScreenLabelColor
                                      : Colors.grey.shade200,
                                  color: hasText
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                  loading: state is SignupLoading,
                                  onPressed:
                                      isloading ? null : () => submitForm(),
                                  text: "Create an account",
                                );
                              });
                            },
                          ),
                          SizedBox(
                            height: 15.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Already have an account?",
                                  style: body.copyWith(
                                      color: Colors.grey.shade700)),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, login);
                                },
                                child: Text("Login",
                                    style: small.copyWith(
                                        color: primary, fontSize: 16.sp)),
                              ),
                            ],
                          ),
                        ],
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
