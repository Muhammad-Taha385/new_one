import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:real_time_chat_application/core/utils/toastmessage_utils.dart';
import 'package:real_time_chat_application/ui/screens/auth/login/loginn_screen.dart';
// import 'package:real_time_chat_application/ui/screens/auth/login/login_screen.dart';
// import 'package:real_time_chat_application/ui/screens/auth/login/new_login_screen.dart';

class SignOutAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future <void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();

      // Navigate to Login Screen
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) =>  LoginScreen()),
          (route) => false, // Clear all previous routes
        );
      }

      // Utilities.showToast(message: "Signed out successfully");
             ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signed out Successfully"),
        backgroundColor: Colors.grey.shade900,
        ),
      );
    } catch (e) {
             ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signed out failed ; ${e.toString()}"),
        backgroundColor: Colors.grey.shade900,
        ),
      );
      // Utilities.showToast(message: "Sign out failed: ${e.toString()}");
    }
  }
}
