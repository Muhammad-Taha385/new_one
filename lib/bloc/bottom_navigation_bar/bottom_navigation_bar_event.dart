import 'package:equatable/equatable.dart';

abstract class BottomNavigationBarEvent extends Equatable {}

class BottomNavigationBarCall extends BottomNavigationBarEvent {
  final int currentindex;
  BottomNavigationBarCall({required this.currentindex});
  @override
  List<Object?> get props => [];
}
