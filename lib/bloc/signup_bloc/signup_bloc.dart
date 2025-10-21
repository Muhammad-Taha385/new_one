import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_time_chat_application/bloc/signup_bloc/signup_event.dart';
import 'package:real_time_chat_application/bloc/signup_bloc/signup_state.dart';
import 'package:real_time_chat_application/core/models/usermodel.dart';
import 'package:real_time_chat_application/core/services/database_service.dart';
import 'package:real_time_chat_application/core/services/signin_auth_service.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final DatabaseService _db;
  final SignupAuthService _authService;
  SignupBloc(this._authService , this._db) : super(SignupInitial()) {
    on<SignupAuth>((event, emit) async {
      emit(SignupLoading());
      final success = await _authService.signup(
        name: event.name,
        email: event.email,
        password: event.password,
        context: event.context,
      );
      if (success != null) {
        Usermodel user = Usermodel(
          uid: success.uid,
          name: event.name,
          email: event.email,
          profileImageUrl: success.photoURL ?? '',
        );
        await _db.saveUser(user.toMap());
        emit(SignupSuccess());
      }
    });
  }
}
