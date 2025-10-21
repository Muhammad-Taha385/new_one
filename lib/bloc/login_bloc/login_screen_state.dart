import 'package:equatable/equatable.dart';

abstract class LoginScreenState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginScreenInitial extends LoginScreenState {}

class LoginScreenLoading extends LoginScreenState {}

class LoginScreenSuccess extends LoginScreenState {}

class LoginScreenError extends LoginScreenState {
  final String message;
  LoginScreenError(this.message);

  @override
  List<Object?> get props => [message];
}
