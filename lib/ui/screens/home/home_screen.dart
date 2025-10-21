// // import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:real_time_chat_application/core/models/usermodel.dart';

// class HomeScreen extends StatelessWidget {
//   // final Usermodel currentUser;
//   // final Usermodel reciever;
//   const HomeScreen(
//     {
//       super.key,
//       // required this.currentUser,
//       // required this.reciever,
//     }
//     );

//   @override
//   Widget build(BuildContext context) {
//     // final FirebaseAuth auth = FirebaseAuth.instance;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: Text(
//           "Updates",
//           style: TextStyle(
//             color: Colors.black,
//             fontFamily: "CarosBold",
//             fontWeight: FontWeight.w400,
//             fontSize: 24.sp,
//           ),
//         ),
//       ),
//       body: SafeArea(
//           child: ListView.separated(
//               // separatorBuilder:,
//               separatorBuilder: (context, index) {
//                 return SizedBox(
//                   height: 5.h,
//                 );
//               },
//               itemCount: 10,
//               itemBuilder: (context, index) {
//                 return Container(
//                   height: 60.h,
//                   child: ListTile(
//                     leading: CircleAvatar(),
//                     title: Text("User"),
//                     trailing: Text(DateTime.now().toString()),
//                   ),
//                 );
//               })),
//     );
//   }
// }
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:real_time_chat_application/bloc/story_bloc/stories_bloc.dart';
import 'package:real_time_chat_application/bloc/story_bloc/stories_state.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';
// import 'package:real_time_chat_application/core/models/usermodel.dart';

class HomeScreen extends StatelessWidget {
  // final Usermodel currentUser;
  // final Usermodel reciever;
  const HomeScreen(
    {
      super.key,
      // required this.currentUser,
      // required this.reciever,
    }
    );

  @override
  Widget build(BuildContext context) {
    // final FirebaseAuth auth = FirebaseAuth.instance;
    final controller = StoryController();

    return Scaffold(
      appBar: AppBar(title: const Text("Stories")),
      body: BlocBuilder<StoryBloc, StoryState>(
        builder: (context, state) {
          if (state is StoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is StoryLoaded) {
            final stories = state.stories;
            return ListView.builder(
              itemCount: stories.length,
              itemBuilder: (context, index) {
                final story = stories[index];
                return ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage(story.mediaUrl)),
                  title: Text(story.fromUid),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StoryView(
                          controller: controller,
                          storyItems: [
                            StoryItem.pageImage(
                              url: story.mediaUrl,
                              controller: controller,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
          return const Center(child: Text("No stories yet"));
        },
      ),
    );

  }
}


