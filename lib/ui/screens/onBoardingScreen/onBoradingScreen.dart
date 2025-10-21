import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
import 'package:real_time_chat_application/core/constants/colors.dart';
import 'package:real_time_chat_application/core/constants/strings.dart';
// import 'package:real_time_chat_application/core/constants/styles.dart';
import 'package:real_time_chat_application/ui/Widgets/TextField/CustomButton.dart';
import 'package:real_time_chat_application/ui/Widgets/TextField/custom_text.dart';
import 'package:real_time_chat_application/ui/Widgets/TextField/svg_image.dart';
import 'package:real_time_chat_application/ui/screens/auth/login/loginn_screen.dart';
// import 'package:real_time_chat_application/ui/screens/auth/login/login_screen.dart';
// import 'package:real_time_chat_application/ui/screens/auth/login/new_login_screen.dart';
// import 'package:real_time_chat_application/ui/screens/auth/signup/signup_screen.dart'; // Adjust path if needed

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              const Color(0xFF43116A).withAlpha(450),
              Colors.black,
            ],
            center: const Alignment(0, -0.6),
            radius: 1.0,
          ),
        ),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 90.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPics(
                  image: onbaordingScreenlogo,
                  height: 42.h,
                  width: 30.w,
                  fit: BoxFit.cover,
                  semanticsLabel: "OnboardingScreenLogo",
                ),
                // SvgPicture.asset(
                //   onbaordingScreenlogo,
                //   height: 30.h,
                //   width: 22.w,
                //   fit: BoxFit.cover,
                //   semanticsLabel: "OnboardingScreenLogo",
                // ),
                SizedBox(
                  width: 20.w,
                ),
                OnBoardingText(
                  text: "Chatbox",
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Circular-Std",
                  fontSize: 28.h,
                  // height: 1.2,
                ),
              ],
            ),
            SizedBox(
              height: 14.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20.w,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OnBoardingText(
                      text: "Connect",
                      color: Colors.white,
                      fontSize: 60.h,
                      fontFamily: "Caros",
                      fontWeight: FontWeight.w300,
                      // height: 1.5,
                    ),
                    OnBoardingText(
                      text: "friends",
                      color: Colors.white,
                      fontSize: 60.h,
                      fontFamily: "Caros",
                      fontWeight: FontWeight.w300,
                      // height: 1.5,
                    ),
                    OnBoardingText(
                      text: "easily &",
                      color: Colors.white,
                      fontSize: 60.h,
                      fontFamily: "Caros",
                      fontWeight: FontWeight.w800,
                      // height: 1.5,
                    ),
                    OnBoardingText(
                      text: "quickly",
                      color: Colors.white,
                      fontSize: 60.h,
                      fontFamily: "Caros",
                      fontWeight: FontWeight.w800,
                      // height: 1.5,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 20.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Our chat app is the perfect to stay",
                  style: TextStyle(
                    color: grey,
                    fontSize: 16.h,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Circular-Std",
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "connected with friends and family.",
                  style: TextStyle(
                    color: grey,
                    fontSize: 16.h,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Circular-Std",
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 22.h,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120.w,
                ),
                // SvgPics(
                //   image:facebooklogo ,
                //   height: 45.h,
                //   width: 45.w,
                //   fit: BoxFit.cover,
                //   semanticsLabel: "facebookLogo",
                // ),
                // // SvgPicture.asset(
                // //   facebooklogo,
                // //   height: 45.h,
                // //   width: 45.w,
                // //   fit: BoxFit.cover,
                // //   semanticsLabel: "facebookLogo",
                // // ),
                // SizedBox(
                //   width: 24.w,
                // ),
                // SvgPics(
                //   image:googlelogo ,
                //   height: 45.h,
                //   width: 45.w,
                //   fit: BoxFit.cover,
                //   semanticsLabel: "googleLogo",
                // ),
                // SvgPicture.asset(
                //   googlelogo,
                //   height: 45.h,
                //   width: 45.w,
                //   fit: BoxFit.cover,
                //   semanticsLabel: "googleLogo",
                // ),
              ],
            ),
            // SizedBox(
            //   height: 15.h,
            // ),
            // Row(
            //   children: [
            //     Expanded(
            //         child: Padding(
            //       padding: EdgeInsets.symmetric(horizontal: 16.w),
            //       child: Divider(color: Colors.grey.shade600),
            //     )),
            //     Padding(
            //       padding: EdgeInsets.symmetric(horizontal: 8.w),
            //       child: Text("OR",
            //           style: body.copyWith(fontSize: 14, color: Colors.white)),
            //     ),
            //     Expanded(
            //         child: Padding(
            //       padding: EdgeInsets.symmetric(horizontal: 16.w),
            //       child: Divider(color: Colors.grey.shade600),
            //     )),
            //   ],
            // ),
            SizedBox(
              height: 15.h,
            ),
            CustomButtonWidget(
              fontSize: 14.sp,
              text: "Start Messaging",
              // loading: ,
              backgroundColor: Colors.white,
              color: primary,
              onPressed: () {
                Navigator.of(context)
                    .pushReplacement(_createSlideFadeRouteToLogin());
              },
            ),
            SizedBox(
              height: 8.h,
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Text("Exiting account?",
            //         style: body.copyWith(color: Colors.grey.shade700)),
            //     TextButton(
            //       onPressed: () => Navigator.of(context).pushReplacement(_createSlideFadeRouteToLogin()),
            //       child: Text("Login",
            //           style: small.copyWith(color: Colors.white, fontSize: 15.sp)),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
      // floatingActionButton: CustomButtonWidget(
      //   text: "Start Messaging",
      //   onPressed: () {
      //     Navigator.of(context).pushReplacement(_createSlideFadeRouteToLogin());
      //   },
      //   key: const Key("startMessagingButton"),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ⬇️ Custom fade transition with pushReplacement
  Route _createSlideFadeRouteToLogin() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 1200),
      pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }
}
