import 'package:equatable/equatable.dart';

abstract class BottomNavigationBarState extends Equatable {}


class BottomNavigationBarSuccess extends BottomNavigationBarState {
  final int currentindex;
  BottomNavigationBarSuccess({this.currentindex = 1});

  BottomNavigationBarSuccess copyWith({int? currentindex}) {
    return BottomNavigationBarSuccess(
      currentindex: this.currentindex
    );
  }

  @override
  List<Object?> get props => [currentindex];
}
