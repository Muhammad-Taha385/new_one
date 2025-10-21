// import 'dart:nativewrappers/_internal/vm/lib/math_patch.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_time_chat_application/bloc/user_provider/user_provider_event.dart';
import 'package:real_time_chat_application/bloc/user_provider/user_provider_state.dart';
import 'package:real_time_chat_application/core/models/usermodel.dart';
import 'package:real_time_chat_application/core/services/database_service.dart';
// import 'dart:developer';

// import 'user_event.dart';
// import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final DatabaseService _db;

  UserBloc(this._db) : super(UserInitial()) {
    on<FetchUser>(_onFetchUser);
    on<ClearUser>(_onClearUser);
  }

  Future<void> _onFetchUser(FetchUser event, Emitter<UserState> emit) async {
    try {
      emit(UserLoading());
      // print("Fetching user for uid: ${event.uid}");

      final res = await _db.loadUser(event.uid);

      if (res != null) {
        // print("User data found: $res");
        final user = Usermodel.fromMap(res);
        emit(UserLoaded(user));
        // log("User Found");
      } else {
        // log("No user found for uid: ${event.uid}");
        emit(const UserError("User not found"));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  void _onClearUser(ClearUser event, Emitter<UserState> emit) {
    emit(UserInitial());
  }
}
