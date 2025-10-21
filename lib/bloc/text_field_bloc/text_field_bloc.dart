// textfield_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_time_chat_application/bloc/text_field_bloc/text_field_event.dart';
import 'package:real_time_chat_application/bloc/text_field_bloc/text_field_state.dart';

class TextFieldBloc extends Bloc<TextFieldEvent, TextFieldState> {
  TextFieldBloc({bool initialObscure = false})
      : super(ToggleObscureState(isObscure: initialObscure)) {
    on<ToggleObscureEvent>((event, emit) {
     final currentState = state as ToggleObscureState;
     emit(currentState.copyWith(isObscure: !currentState.isObscure));
    });
  }
}
