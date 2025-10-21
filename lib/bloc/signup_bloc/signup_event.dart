import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_storage/firebase_storage.dart';

abstract class SignupEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignupAuth extends SignupEvent {
  final String name;
  final String email;
  final String password;
  final BuildContext context;
  // final String confirmpassword;
  SignupAuth(
      {required this.email,
      required this.password,
      required this.context,
      required this.name});

  @override
  List<Object?> get props => [email, password, name, context];
}
