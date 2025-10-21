// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:real_time_chat_application/bloc/story_bloc/stories_bloc.dart';
// import 'package:real_time_chat_application/bloc/story_bloc/stories_event.dart';
// import 'package:real_time_chat_application/bloc/story_bloc/stories_state.dart';
// import 'package:real_time_chat_application/bloc/file_picker_bloc/file_picker_bloc.dart';
// import 'package:real_time_chat_application/bloc/file_picker_bloc/file_picker_event.dart';
// import 'package:real_time_chat_application/bloc/file_picker_bloc/file_picker_state.dart';

// class StoryUploadPage extends StatelessWidget {
//   final String currentUid;
//   const StoryUploadPage({super.key, required this.currentUid});

//   void _uploadTextStory(BuildContext context) {
//     final controller = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Write Story"),
//         content: TextField(
//           controller: controller,
//           decoration: const InputDecoration(hintText: "Type your story..."),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               final text = controller.text.trim();
//               if (text.isNotEmpty) {
//                 context
//                     .read<StoryBloc>()
//                     .add(UploadTextStory(currentUid, text));
//                 Navigator.pop(context);
//               }
//             },
//             child: const Text("Upload"),
//           )
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Add Story")),
//       body: MultiBlocListener(
//         listeners: [
//           BlocListener<StoryBloc, StoryState>(
//             listener: (context, state) {
//               if (state is StoryUploaded) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("Story uploaded successfully!")),
//                 );
//                 // context.read<ImagePickerBloc>().add(GalleryPicker()); // reset if needed
//               }
//             },
//           ),
//         ],
//         child: BlocBuilder<ImagePickerBloc, ImagePickerState>(
//           builder: (context, imageState) {
//             return BlocBuilder<StoryBloc, StoryState>(
//               builder: (context, storyState) {
//                 if (storyState is StoryLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (storyState is StoryError) {
//                   return Center(child: Text("Error: ${storyState.error}"));
//                 }

//                 final selectedFile = imageState.file != null
//                     ? File(imageState.file!.path)
//                     : null;

//                 return Center(
//                   child: Padding(
//                     padding: const EdgeInsets.all(20),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         if (selectedFile != null) ...[
//                           ClipRRect(
//                             borderRadius: BorderRadius.circular(12),
//                             child: Image.file(
//                               selectedFile,
//                               height: 250,
//                               width: double.infinity,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           ElevatedButton.icon(
//                             icon: const Icon(Icons.cloud_upload),
//                             label: const Text("Upload Story"),
//                             onPressed: () {
//                               final uid =
//                                   FirebaseAuth.instance.currentUser!.uid;
//                               context
//                                   .read<StoryBloc>()
//                                   .add(UploadStory(uid, selectedFile.path));
//                             },
//                           ),
//                           const SizedBox(height: 16),
//                           TextButton.icon(
//                             icon: const Icon(Icons.close),
//                             label: const Text("Cancel"),
//                             onPressed: () {
//                               // Clear selected image
//                               context
//                                   .read<ImagePickerBloc>()
//                                   .emit(const ImagePickerState());
//                             },
//                           ),
//                         ] else ...[
//                           ElevatedButton.icon(
//                             icon: const Icon(Icons.image),
//                             label: const Text("Pick Image Story"),
//                             onPressed: () {
//                               context
//                                   .read<ImagePickerBloc>()
//                                   .add(GalleryPicker());
//                             },
//                           ),
//                           const SizedBox(height: 16),
//                           ElevatedButton.icon(
//                             icon: const Icon(Icons.text_fields),
//                             label: const Text("Upload Text Story"),
//                             onPressed: () => _uploadTextStory(context),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:real_time_chat_application/bloc/story_bloc/stories_bloc.dart';
import 'package:real_time_chat_application/bloc/story_bloc/stories_event.dart';
import 'package:real_time_chat_application/bloc/story_bloc/stories_state.dart';
import 'package:real_time_chat_application/bloc/file_picker_bloc/file_picker_bloc.dart';
import 'package:real_time_chat_application/bloc/file_picker_bloc/file_picker_event.dart';
import 'package:real_time_chat_application/bloc/file_picker_bloc/file_picker_state.dart';

class StoryUploadPage extends StatelessWidget {
  final String currentUid;
  const StoryUploadPage({super.key, required this.currentUid});

  void _uploadTextStory(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Write Story"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Type your story..."),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                context.read<StoryBloc>().add(UploadTextStory(currentUid, text));
                Navigator.pop(context); // close dialog
              }
            },
            child: const Text("Upload"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Story")),
      body: MultiBlocListener(
        listeners: [
          BlocListener<StoryBloc, StoryState>(
            listener: (context, state) {
              if (state is StoryUploaded) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Story uploaded successfully!")),
                );

                // ✅ Clear picked file
                context.read<ImagePickerBloc>().add(ClearPickedFile());

                // ✅ Go back to story page
                Navigator.pop(context);

                // ✅ Refresh stories on StoryPage
                context.read<StoryBloc>().add(FetchAllStories());
              } else if (state is StoryError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: ${state.error}")),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<ImagePickerBloc, ImagePickerState>(
          builder: (context, imageState) {
            return BlocBuilder<StoryBloc, StoryState>(
              builder: (context, storyState) {
                if (storyState is StoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final selectedFile =
                    imageState.file != null ? File(imageState.file!.path) : null;

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (selectedFile != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              selectedFile,
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.cloud_upload),
                            label: const Text("Upload Story"),
                            onPressed: () {
                              final uid =
                                  FirebaseAuth.instance.currentUser!.uid;
                              context
                                  .read<StoryBloc>()
                                  .add(UploadStory(uid, selectedFile.path));
                            },
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            icon: const Icon(Icons.close),
                            label: const Text("Cancel"),
                            onPressed: () {
                              context
                                  .read<ImagePickerBloc>()
                                  .add(ClearPickedFile());
                            },
                          ),
                        ] else ...[
                          ElevatedButton.icon(
                            icon: const Icon(Icons.image),
                            label: const Text("Pick Image Story"),
                            onPressed: () {
                              context
                                  .read<ImagePickerBloc>()
                                  .add(GalleryPicker());
                            },
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.text_fields),
                            label: const Text("Upload Text Story"),
                            onPressed: () => _uploadTextStory(context),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

