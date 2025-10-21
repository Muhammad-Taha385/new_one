// part of 'image_picker_bloc.dart';

import 'package:equatable/equatable.dart';

abstract class ImagePickerEvent extends Equatable{
  const ImagePickerEvent();

  @override
  List<Object> get props => [];
}


// class CameraCapture extends ImagePickerEvent {}
class GalleryPicker extends ImagePickerEvent {}
class ClearPickedFile extends ImagePickerEvent {} // ✅ Add this
