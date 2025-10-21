import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Signs up a user and handles feedback internally
  Future<User?> signup({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final User? user = userCredential.user;

      // Set user's display name
      await user?.updateDisplayName(name.trim());

      // Send email verification
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();

        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Verify Your Email"),
            content: Text(
              "A verification link has been sent to ${user.email}. "
              "Please check your inbox and verify your email before logging in.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful!")),
      );
      return userCredential.user ;
    } on FirebaseAuthException catch (e) {
      _showError(context, _handleFirebaseError(e));
      // return false;
    } catch (_) {
      _showError(context, "An unexpected error occurred. Please try again.");
      // return false;
    }
    return null;
  }

  /// Converts FirebaseAuthException codes to readable messages
  String _handleFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return "This email is already registered.";
      case 'weak-password':
        return "Password is too weak. Use at least 8 characters.";
      case 'invalid-email':
        return "The email address format is invalid.";
      default:
        return "Registration failed: ${e.message}";
    }
  }

  /// Shows a standardized error message
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.grey.shade900,
      ),
    );
  }
}

