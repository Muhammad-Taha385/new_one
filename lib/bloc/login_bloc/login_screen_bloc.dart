import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_time_chat_application/bloc/login_bloc/login_screen_event.dart';
import 'package:real_time_chat_application/bloc/login_bloc/login_screen_state.dart';
import 'package:real_time_chat_application/core/models/usermodel.dart';
import 'package:real_time_chat_application/core/services/login_auth_service.dart';
import 'package:real_time_chat_application/core/services/google_auth_service.dart';
import 'package:real_time_chat_application/core/services/database_service.dart';

class LoginScreenBloc extends Bloc<LoginScreenEvent, LoginScreenState> {
  final LoginAuthService _authService;
  final GoogleAuthService _googleAuthService;
  final DatabaseService _databaseService;

  LoginScreenBloc(
    this._authService,
    this._googleAuthService,
    this._databaseService,
  ) : super(LoginScreenInitial()) {
    on<LoginAuth>((event, emit) async {
      emit(LoginScreenLoading());
      try {
        final success = await _authService.login(
          email: event.email,
          password: event.password,
          context: event.context,
        );

        if (success) {
          emit(LoginScreenSuccess());
        } else {
          emit(LoginScreenError(
              "Login failed. Email not verified or cancelled."));
        }
      } catch (e) {
        emit(LoginScreenError(e.toString()));
          emit(LoginScreenInitial()); // 👈 reset UI back to normal

      }
    });

    on<GoogleAuth>((event, emit) async {
      emit(LoginScreenLoading());
      try {
        final res = await _googleAuthService.signInWithGoogle();
        if (res != null) {
          Usermodel user = Usermodel(
              uid: res.user?.uid ?? "",
              name: res.user?.displayName ?? "",
              email: res.user?.email ?? "",
              profileImageUrl: res.user?.photoURL ?? "");
          // Store user in database if needed
          await _databaseService.saveUser(user .toMap());
          emit(LoginScreenSuccess());
        } else {
          emit(LoginScreenError("Google login cancelled"));
        }
      } catch (e) {
        emit(LoginScreenError(e.toString()));
      }
    });
  }
}
