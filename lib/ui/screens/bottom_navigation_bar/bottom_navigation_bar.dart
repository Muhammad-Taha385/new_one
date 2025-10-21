// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:real_time_chat_application/core/constants/colors.dart';
// import 'package:real_time_chat_application/core/constants/strings.dart';
// import 'package:real_time_chat_application/ui/screens/Chatscreen/chat_screen.dart';
// import 'package:real_time_chat_application/ui/screens/ProfileScreen/profile_screen.dart';
// // import 'package:real_time_chat_application/ui/screens/bottom_nav/bottom_navigation_model.dart'; // Adjust path
// import 'package:real_time_chat_application/ui/screens/bottom_navigation_bar/bottom_navigation_bar_model.dart';
// import 'package:real_time_chat_application/ui/screens/home/home_screen.dart';
// // import 'package:real_time_chat_application/ui/screens/chat/chat_screen.dart';
// // import 'package:real_time_chat_application/ui/screens/profile/profile_screen.dart';

// class MyBottomNavigationBar extends StatelessWidget {
//   MyBottomNavigationBar({super.key});

//   final List<Widget> _screens = const [
//     HomeScreen(),
//     ChatScreen(),
//     ProfileScreen(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final navModel = Provider.of<BottomNavigationBarModel>(context);

//     return Scaffold(
//       body: IndexedStack(
//         index: navModel.currentindex,
//         children: _screens,
//       ),
//       bottomNavigationBar: Container(
//         height: 70,
//         decoration: BoxDecoration(
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(40),
//             topRight: Radius.circular(40),
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               spreadRadius: 2,
//               blurRadius: 5,
//               offset: const Offset(0, -2),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(40),
//             topRight: Radius.circular(40),
//           ),
//           child: BottomNavigationBar(
//             selectedItemColor: Colors.black,
//             unselectedItemColor: Colors.grey[600],
//             currentIndex: navModel.currentindex,
//             onTap: navModel.onTap,
//             items: const [
//               BottomNavigationBarItem(
//                 icon: Padding(
//                   padding: EdgeInsets.only(top: 10),
//                   child: ImageIcon(
//                     AssetImage(homeIcon),
//                     size: 24,
//                   ),
//                 ),
//                 label: 'Home',
//               ),
//               BottomNavigationBarItem(
//                 icon: Padding(
//                   padding: EdgeInsets.only(top: 10),
//                   child: ImageIcon(
//                     AssetImage(chatIcon),
//                     size: 24,
//                   ),
//                 ),
//                 label: 'Chats',
//               ),
//               BottomNavigationBarItem(
//                 icon: Padding(
//                   padding: EdgeInsets.only(top: 10),
//                   child: ImageIcon(
//                     AssetImage(profileIcon),
//                     size: 24,
//                   ),
//                 ),
//                 label: 'Profile',
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// import 'dart:nativewrappers/_internal/vm/lib/math_patch.dart';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'dart:developer';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import 'package:real_time_chat_application/bloc/bottom_navigation_bar/bottom_navigation_bar_bloc.dart';
// import 'package:real_time_chat_application/bloc/bottom_navigation_bar/bottom_navigation_bar_event.dart';
// import 'package:real_time_chat_application/bloc/bottom_navigation_bar/bottom_navigation_bar_state.dart';
// import 'package:real_time_chat_application/bloc/contact_model_bloc.dart/contact_model_bloc.dart';
// import 'package:real_time_chat_application/bloc/contact_model_bloc.dart/contact_model_event.dart';
// import 'package:real_time_chat_application/core/constants/colors.dart';
// import 'package:real_time_chat_application/core/constants/strings.dart';
// import 'package:real_time_chat_application/core/services/database_service.dart';
// // import 'package:real_time_chat_application/ui/screens/Chatscreen/chat_screen.dart';
// import 'package:real_time_chat_application/ui/screens/Chatscreen/new_chat_screen.dart';
// import 'package:real_time_chat_application/ui/screens/ProfileScreen/profile_screen.dart';
// import 'package:real_time_chat_application/ui/screens/contact_screen/contact_screen.dart';
// // import 'package:real_time_chat_application/ui/screens/bottom_navigation_bar/bottom_navigation_bar_model.dart';
// import 'package:real_time_chat_application/ui/screens/home/home_screen.dart';

// class MyBottomNavigationBar extends StatelessWidget {
//   MyBottomNavigationBar({super.key});
//   //   final currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";

//   // final List<Widget> _screens = [
//   //   const HomeScreen(),
//   //   ChatScreen(currentUid:currentUid ,),
//   //   const ProfileScreen(),
//   // ];

//   @override
//   Widget build(BuildContext context) {
//     final currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";

//     log("Id is ${currentUid}");
//     final List<Widget> _screens = [
//       const HomeScreen(),
//       // log(x)
//       // ChatScreen(
//       //   currentUid: currentUid,
//       // ),
//     BlocProvider(
//     create: (_) => ContactBloc(DatabaseService())
//       ..add(LoadfriendsContacts(currentUid)),
//     child: NewChatScreen(currentUid: currentUid),
//   ),
//       ContactScreen(currentUserId: currentUid),
//       // ChatScreen(),
//       const ProfileScreen(),
//     ];
//     // final navModel = Provider.of<BottomNavigationBarModel>(context);
//     print("Rebuild");
//     return Scaffold(
//       body: BlocBuilder<BottomNavigationBarBloc, BottomNavigationBarState>(
//         builder: (context, state) {
//           if (state is BottomNavigationBarSuccess) {
//             return IndexedStack(
//               index: state.currentindex,
//               children: _screens,
//             );
//           }
//           return const SizedBox.shrink(); // fallback while initializing
//         },
//       ),
//       bottomNavigationBar: Container(
//         height: 65.h,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.only(
//             // topLeft: Radius.circular(50.r),
//             // topRight: Radius.circular(50.r),
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               spreadRadius: 2,
//               blurRadius: 5,
//               offset: const Offset(0, -2),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.only(
//             // topLeft: Radius.circular(50.r),
//             // topRight: Radius.circular(50.r),
//           ),
//           child: BlocBuilder<BottomNavigationBarBloc, BottomNavigationBarState>(
//             builder: (context, state) {
//               if (state is BottomNavigationBarSuccess) {
//                 return BottomNavigationBar(
//                   currentIndex: state.currentindex,
//                   onTap: (index) {
//                     context
//                         .read<BottomNavigationBarBloc>()
//                         .add(BottomNavigationBarCall(currentindex: index));
//                   },
//                   selectedItemColor: loginScreenLabelColor,
//                   showUnselectedLabels: true,
//                   unselectedItemColor: Colors.grey[600],
//                   items: [
//                     _buildAnimatedItem(context, 0, homeIcon, 'Home', state),
//                     _buildAnimatedItem(context, 1, chatIcon, 'Chats', state),
//                     _buildAnimatedItem(context, 2, contactIcon, "Contacts", state),
//                     _buildAnimatedItem(context, 3, profileIcon, 'Profile', state),
//                   ],
//                 );
//               }
//               return const SizedBox.shrink();
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   BottomNavigationBarItem _buildAnimatedItem(
//     BuildContext context,
//     int? index,
//     String iconPath,
//     String label,
//     BottomNavigationBarState state,
//   ) {
//     final isSelected =
//         state is BottomNavigationBarSuccess && index == state.currentindex;

//     return BottomNavigationBarItem(
//       icon: AnimatedScale(
//         duration: const Duration(milliseconds: 300),
//         scale: isSelected ? 1.1 : 1.0,
//         curve: Curves.decelerate,
//         child: ImageIcon(
//           AssetImage(iconPath),
//           size: 24.sp,
//           color: isSelected ? loginScreenLabelColor : Colors.grey[600],
//         ),
//       ),
//       label: label,

//     );
//   }
// }

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:real_time_chat_application/bloc/bottom_navigation_bar/bottom_navigation_bar_bloc.dart';
import 'package:real_time_chat_application/bloc/bottom_navigation_bar/bottom_navigation_bar_event.dart';
import 'package:real_time_chat_application/bloc/bottom_navigation_bar/bottom_navigation_bar_state.dart';
import 'package:real_time_chat_application/core/constants/colors.dart';
import 'package:real_time_chat_application/core/constants/strings.dart';
import 'package:real_time_chat_application/core/models/usermodel.dart';
import 'package:real_time_chat_application/ui/screens/Chatscreen/new_chat_screen.dart';
import 'package:real_time_chat_application/ui/screens/ProfileScreen/profile_screen.dart';
import 'package:real_time_chat_application/ui/screens/contact_screen/contact_screen.dart';
import 'package:real_time_chat_application/ui/screens/home/home_screen.dart';
import 'package:real_time_chat_application/ui/screens/story_upload_page/story_page.dart';
import 'package:real_time_chat_application/ui/screens/story_upload_page/story_upload_page.dart';

class MyBottomNavigationBar extends StatefulWidget {
  const MyBottomNavigationBar({super.key});

  @override
  State<MyBottomNavigationBar> createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  late final String currentUid;
  late final List<Widget> _screens;
  late final Usermodel currentUser;

  @override
  void initState(){
    super.initState();
    currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";
    log("Current user ID: $currentUid");
    // final currentUserDoc = await FirebaseFirestore.instance
    //    .collection("users")
    //    .doc(currentUid)
    //    .get();

    // currentUser = Usermodel.fromMap(currentUserDoc.data()!);

    _screens = [
      // HomeScreen(
        
      //   // currentUser: currentUser,
      //   // reciever: ,
      // ),
      // StoryUploadPage(currentUid: currentUid),
      StoryPage(),
      NewChatScreen(currentUid: currentUid,),
      ContactScreen(currentUserId: currentUid),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<BottomNavigationBarBloc, BottomNavigationBarState>(
        builder: (context, state) {
          if (state is BottomNavigationBarSuccess) {
            return IndexedStack(
              index: state.currentindex,
              children: _screens,
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: Container(
        height: 65.h,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          child: BlocBuilder<BottomNavigationBarBloc, BottomNavigationBarState>(
            builder: (context, state) {
              if (state is BottomNavigationBarSuccess) {
                return BottomNavigationBar(
                  currentIndex: state.currentindex,
                  onTap: (index) {
                    context
                        .read<BottomNavigationBarBloc>()
                        .add(BottomNavigationBarCall(currentindex: index));
                  },
                  selectedItemColor: loginScreenLabelColor,
                  unselectedItemColor: Colors.grey[600],
                  showUnselectedLabels: true,
                  items: [
                    _buildAnimatedItem(0, homeIcon, 'Home', state),
                    _buildAnimatedItem(1, chatIcon, 'Chats', state),
                    _buildAnimatedItem(2, contactIcon, 'Contacts', state),
                    _buildAnimatedItem(3, profileIcon, 'Profile', state),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildAnimatedItem(
    int index,
    String iconPath,
    String label,
    BottomNavigationBarState state,
  ) {
    final isSelected =
        state is BottomNavigationBarSuccess && index == state.currentindex;

    return BottomNavigationBarItem(
      icon: AnimatedScale(
        duration: const Duration(milliseconds: 300),
        scale: isSelected ? 1.1 : 1.0,
        child: ImageIcon(
          AssetImage(iconPath),
          size: 24.sp,
          color: isSelected ? loginScreenLabelColor : Colors.grey[600],
        ),
      ),
      label: label,
    );
  }
}
