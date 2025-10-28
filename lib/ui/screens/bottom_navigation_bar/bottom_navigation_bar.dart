import 'dart:developer';
// import 'package:cloud_firestore/cloud_firestore.dart';
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
// import 'package:real_time_chat_application/ui/screens/home/home_screen.dart';
import 'package:real_time_chat_application/ui/screens/story_upload_page/story_page.dart';
// import 'package:real_time_chat_application/ui/screens/story_upload_page/story_upload_page.dart';

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
  void initState() {
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
      NewChatScreen(
        currentUid: currentUid,
      ),
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
        // height: 65.h,
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
