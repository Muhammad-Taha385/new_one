import 'dart:io';
import 'package:file_picker/file_picker.dart';

class StoryFilePickerService {
  /// Pick image or video from file system
  Future<File?> pickStoryFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov' ,'webm'],
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      } else {
        return null; // User canceled
      }
    } catch (e) {
      print("File picking error: $e");
      return null;
    }
  }
}
