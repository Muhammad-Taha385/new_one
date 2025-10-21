import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class FetchUser extends UserEvent {
  final String uid;
  const FetchUser(this.uid);

  @override
  List<Object?> get props => [uid];
}

class ClearUser extends UserEvent {}
