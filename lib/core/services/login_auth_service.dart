import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:real_time_chat_application/core/constants/strings.dart';
// import 'package:real_time_chat_application/core/utils/toastmessage_utils.dart';
// import 'package:real_time_chat_application/ui/screens/others/user_provider.dart';

class LoginAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = FirebaseAuth.instance.currentUser;

      // ✅ Check if email is verified
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();

        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Email Not Verified"),
            content: Text(
              "A verification email has been sent to ${user.email}. "
              "Please verify your email before logging in.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );

        await FirebaseAuth.instance.signOut(); // ⛔ Sign out unverified user
        return false ;
      }

      // ✅ Email is verified, allow login
      // Utilities.showSuccess("Logged in Successfully");
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logged in Successfully"),
        backgroundColor: Colors.grey.shade900,
        ),
      );
      // Fetch user data and navigate to home screen
      // final userProvider = Provider.of<UserProvider>(context, listen: false);
      // userProvider.fetchUserData(user!.uid);
      // Navigate to home screen
      Navigator.pushReplacementNamed(
        context,
        wrapper,
  //       arguments: {
  //   "currentUser": currentUser,
  //   "receiver": receiverUser,
  // },
        // arguments: user?.uid, // Pass user ID to HomeScreen
      );
      return true;
    }
     on FirebaseAuthException catch (e) {
      // throw _handleFirebaseAuthError(e);
      _showError(context, _handleFirebaseAuthError(e));
      return false;

    } catch (e) {
      throw Exception('Something went wrong. Try again.');
    }
  }

String _handleFirebaseAuthError(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
      return 'No user found with this email.';
    case 'wrong-password':
      return 'The password you entered is incorrect.';
    case 'invalid-email':
      return 'The email address is not valid.';
    case 'user-disabled':
      return 'This user account has been disabled.';
    case 'too-many-requests':
      return 'Too many login attempts. Please try again later.';
    case 'network-request-failed':
      return 'No internet connection. Please check your network.';
    default:
      debugPrint('Unhandled FirebaseAuthException code: ${e.code}');
      return 'Login failed. ${e.message ?? "An unknown error occurred."}';
  }
}
 void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.grey.shade900,
      ),
    );
  }

}
