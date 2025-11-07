import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:real_time_chat_application/core/constants/strings.dart';
import 'package:real_time_chat_application/ui/screens/wrapper/new_wrapper.dart';
import 'package:real_time_chat_application/ui/screens/wrapper/wrapper.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  bool _initializing = true;
  String? _errorMessage;

  @override
void initState() {
  super.initState();
  _startSplashTimer();
}

void _startSplashTimer() {
  try {
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                 UserSessionHandling(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;
              final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(position: animation.drive(tween), child: child);
            },
            transitionDuration: const Duration(milliseconds: 2100),
          ),
        );
      }
    });
  } catch (e) {
    setState(() {
      _errorMessage = 'Failed to initialize app. Please restart.';
    });
  } finally {
    if (mounted) {
      setState(() {
        _initializing = false;
      });
    }
  }
}

@override
void dispose() {
  _timer?.cancel();
  super.dispose();
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            frame,
            height: 1.sh,
            width: 1.sw,
            fit: BoxFit.cover,
            semanticLabel: 'Splash background',
          ),
          // Centered logo
          Center(
            child: SvgPicture.asset(
              changedLogo,
              height: 140.h,
              width: 140.w,
              fit: BoxFit.cover,
              semanticsLabel: 'App logo',
            ),
          ),
          // Optional loading indicator or error message
          if (_initializing)
            const Center(child: CircularProgressIndicator())
          else if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
