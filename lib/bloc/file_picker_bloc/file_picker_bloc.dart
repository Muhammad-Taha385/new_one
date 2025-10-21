// // import 'package:bloc/bloc.dart';
// // import 'package:equatable/equatable.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:real_time_chat_application/bloc/file_picker_bloc/file_picker_event.dart';
// import 'package:real_time_chat_application/bloc/file_picker_bloc/file_picker_state.dart';
// import 'package:real_time_chat_application/core/services/image_picker_service.dart';

// class ImagePickerBloc extends Bloc<ImagePickerEvent, ImagePickerState> {
//   final ImagePickerUtils imagePickerUtils;
//   ImagePickerBloc(
//       this.imagePickerUtils
//       ) : super(const ImagePickerState()) {
//     // on<CameraCapture>(_cameraCapture);
//     on<GalleryPicker>(_galleryPicker);
//     on<ClearPickedFile>(_onClearPickedFile); // ✅ handle this

//   }

//   // void _cameraCapture(CameraCapture event , Emitter<ImagePickerState> emit)async{
//   //   XFile? file = await imagePickerUtils.cameraCapture();
//   //   emit(state.copyWith(file: file));
//   // }

//   void _galleryPicker(
//       GalleryPicker event, Emitter<ImagePickerState> emit) async {
//     XFile? file = await imagePickerUtils.pickImageFromGallery();
//     emit(state.copyWith(file: file));
//   }
// }
//   void _onClearPickedFile(
//       ClearPickedFile event, Emitter<ImagePickerState> emit) {
//     emit(const ImagePickerState()); // ✅ reset to initial
//   }

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:real_time_chat_application/bloc/file_picker_bloc/file_picker_event.dart';
import 'package:real_time_chat_application/bloc/file_picker_bloc/file_picker_state.dart';
import 'package:real_time_chat_application/core/services/image_picker_service.dart';

class ImagePickerBloc extends Bloc<ImagePickerEvent, ImagePickerState> {
  final ImagePickerUtils imagePickerUtils;

  ImagePickerBloc(this.imagePickerUtils) : super(const ImagePickerState()) {
    on<GalleryPicker>(_galleryPicker);
    on<ClearPickedFile>(_onClearPickedFile); // ✅ register here
  }

  Future<void> _galleryPicker(
      GalleryPicker event, Emitter<ImagePickerState> emit) async {
    XFile? file = await imagePickerUtils.pickImageFromGallery();
    emit(state.copyWith(file: file));
  }

  void _onClearPickedFile(
      ClearPickedFile event, Emitter<ImagePickerState> emit) {
    emit(const ImagePickerState()); // ✅ resets to initial state
  }
}
