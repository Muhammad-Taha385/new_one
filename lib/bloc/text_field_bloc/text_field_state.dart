abstract class TextFieldState {}

class ToggleObscureState extends TextFieldState {
  final bool isObscure;

  ToggleObscureState({required this.isObscure});

  ToggleObscureState copyWith({bool? isObscure}) {
    return ToggleObscureState(isObscure: isObscure ?? this.isObscure);
  }
}
