// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_time_chat_application/bloc/bottom_navigation_bar/bottom_navigation_bar_event.dart';
import 'package:real_time_chat_application/bloc/bottom_navigation_bar/bottom_navigation_bar_state.dart';

class BottomNavigationBarBloc
    extends Bloc<BottomNavigationBarEvent, BottomNavigationBarState> {
  BottomNavigationBarBloc()
      : super(BottomNavigationBarSuccess(currentindex: 1)) {
    on<BottomNavigationBarCall>((event, emit) {
      emit(BottomNavigationBarSuccess(currentindex: event.currentindex));
    });
  }
}
