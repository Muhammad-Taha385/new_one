import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class LoginScreenEvent extends Equatable {
  @override
  List<Object?> get props => [];
}
class LoginAuth extends LoginScreenEvent {
  final String email;
  final String password;
  final BuildContext context;

  LoginAuth({
    required this.email,
    required this.password,
    required this.context,
  });

  @override
  List<Object?> get props => [email, password, context];
}

class GoogleAuth extends LoginScreenEvent {
  final BuildContext context;

  GoogleAuth({required this.context});

  @override
  List<Object?> get props => [context];
}
