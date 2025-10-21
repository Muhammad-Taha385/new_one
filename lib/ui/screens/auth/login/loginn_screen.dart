import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:real_time_chat_application/bloc/login_bloc/login_screen_bloc.dart';
import 'package:real_time_chat_application/bloc/login_bloc/login_screen_event.dart';
import 'package:real_time_chat_application/bloc/login_bloc/login_screen_state.dart';

import 'package:real_time_chat_application/core/constants/colors.dart';
import 'package:real_time_chat_application/core/constants/strings.dart';
import 'package:real_time_chat_application/core/constants/styles.dart';
import 'package:real_time_chat_application/ui/Widgets/TextField/CustomButton.dart';

import 'package:real_time_chat_application/ui/Widgets/TextField/custom_text.dart';

import 'package:real_time_chat_application/ui/Widgets/TextField/textfield.dart';



class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      context.read<LoginScreenBloc>().add(
            LoginAuth(
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
              context: context
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w).copyWith(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 100.h),
                OnBoardingText(
                  text: "Log in to Chatbox",
                  color: primary,
                  fontSize: 30.sp,
                  fontFamily: "CarosBold",
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 20.h),
                OnBoardingText(
                  text: "Welcome back! Sign in using your social",
                  color: grey,
                  fontFamily: "Circular-Std",
                  fontSize: 15.sp,
                  height: 1.5,
                ),
                OnBoardingText(
                  text: "account or email to continue us",
                  color: grey,
                  fontFamily: "Circular-Std",
                  fontSize: 15.sp,
                  height: 1.5,
                ),
                SizedBox(height: 20.h),
      
                /// Email
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: CustomTextField(
                    labelText: "Your email",
                    controller: emailController,
                    validate: _emailValidate,
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
      
                /// Password
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: CustomTextField(
                    labelText: "Password",
                    controller: passwordController,
                    validate: _passwordValidate,
                    isObscure: true,
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
      
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _showForgotPasswordDialog(context),
                    child: Text(
                      "Forgot Password?",
                      style: body.copyWith(
                        color: loginScreenLabelColor,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
      
                /// BlocBuilder for Login Button
                BlocBuilder<LoginScreenBloc, LoginScreenState>(
                  builder: (context, state) {
                    final isLoading = state is LoginScreenLoading;
                    return CustomButtonWidget(
                      fontSize: 15,
                      backgroundColor: loginScreenLabelColor,
                      color: Colors.white,
                      loading: isLoading,
                      onPressed: isLoading ? null : () => submitForm(context),
                      text: "Login",
                    );
                  },
                ),
      
                SizedBox(height: 30.h),
                Row(
                  children: [
                    Expanded(
                        child: Divider(color: Colors.grey, thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Text(
                        "Or continue with",
                        style: body.copyWith(fontSize: 14, color: primary),
                      ),
                    ),
                    Expanded(
                        child: Divider(color: Colors.grey, thickness: 1)),
                  ],
                ),
                SizedBox(height: 15.h),
                buildGoogleLoginButton(context),
                SizedBox(height: 10.h),
                // buildFacebookLoginButton(context),
                // SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?",
                        style: body.copyWith(color: Colors.grey.shade700)),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, signup);
                      },
                      child: Text(
                        "Sign Up",
                        style: small.copyWith(color: primary, fontSize: 16.sp),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _emailValidate(String? value) {
    if (value == null || value.isEmpty) return "Please enter an email";
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) return "Please enter a valid email";
    return null;
  }

  String? _passwordValidate(String? value) {
    if (value == null || value.isEmpty) return "Please enter password";
    if (value.length < 8) return "Password must be at least 8 characters";
    return null;
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController resetEmailController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Reset Password"),
        content: TextFormField(
          controller: resetEmailController,
          decoration: InputDecoration(
            hintText: "Email",
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isEmpty) return;
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Reset link sent")),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: ${e.toString()}")),
                );
              }
              Navigator.pop(context);
            },
            child: Text("Send"),
          ),
        ],
      ),
    );
  }

  Widget buildGoogleLoginButton(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<LoginScreenBloc>().add(GoogleAuth(context: context));
      },
      child: Container(
        width: 310.w,
        height: 45.h,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(13.r),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(glogo, height: 24.h),
              SizedBox(width: 12.w),
              Text("Sign in with Google"),
            ],
          ),
        ),
      ),
    );
  }

//   Widget buildFacebookLoginButton(BuildContext context) {
//     return InkWell(
//       // onTap: () {
//       //   context.read<LoginBloc>().add(FacebookLoginPressed());
//       // },
//       child: Container(
//         width: 310.w,
//         height: 45.h,
//         decoration: BoxDecoration(
//           color: Colors.grey.shade300,
//           borderRadius: BorderRadius.circular(13.r),
//         ),
//         child: Center(
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SvgPics(
//                 image: facebooklogin,
//                 height: 24.h,
//                 fit: BoxFit.cover,
//               ),
//               SizedBox(width: 12.w),
//               Text("Sign in with Facebook"),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
}