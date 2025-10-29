// import 'dart:math';

// import 'dart:nativewrappers/_internal/vm/lib/developer.dart';

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:real_time_chat_application/bloc/contact_model_bloc.dart/contact_model_bloc.dart';
import 'package:real_time_chat_application/bloc/contact_model_bloc.dart/contact_model_event.dart';
import 'package:real_time_chat_application/bloc/contact_model_bloc.dart/contact_model_state.dart';
import 'package:real_time_chat_application/core/constants/colors.dart';
import 'package:real_time_chat_application/core/constants/strings.dart';
import 'package:real_time_chat_application/core/constants/styles.dart';
import 'package:real_time_chat_application/core/models/message_model.dart';
import 'package:real_time_chat_application/core/models/usermodel.dart';
// import 'package:real_time_chat_application/core/services/database_service.dart';
import 'package:real_time_chat_application/ui/Widgets/TextField/search_text_field.dart';
import 'package:shimmer/shimmer.dart';
// import 'package:auto_size_text/auto_size_text.dart';

class NewChatScreen extends StatefulWidget {
  final String currentUid;

  const NewChatScreen({super.key, required this.currentUid});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  // late final ContactBloc contactBloc;

  Future<String> _getFirstLetter() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return "?";

    final doc =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (!doc.exists) return "?";

    final name = doc.data()?["name"] ?? "";
    return name.isNotEmpty ? name[0].toUpperCase() : "?";
  }

  @override
  void initState() {
    super.initState();

    // contactBloc = ContactBloc(DatabaseService())
    //   ..add(LoadfriendsContacts(widget.currentUid));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // await Future.delayed(Duration(seconds: 4));
      // Future.delayed(Duration(seconds: 2));
      final contactBloc = context.read<ContactBloc>();
      if (contactBloc.state is! ContactScreenLoaded) {
        contactBloc.add(LoadfriendsContacts(widget.currentUid));
      }
    });
  }

  String _getChatId(String uid1, String uid2) {
    // Sort both IDs lexicographically (alphabetical order)
    final sorted = [uid1, uid2]..sort();
    return "${sorted.first}_${sorted.last}";
  }

  // String _formatTime(DateTime time) {
  //   final now = DateTime.now();
  //   final diff = now.difference(time);

  //   if (diff.inMinutes < 1) return "just now";
  //   if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
  //   if (diff.inHours < 24) return "${diff.inHours} h ago";
  //   if (diff.inDays == 1) return "Yesterday";
  //   return "${time.day}/${time.month}/${time.year}";
  // }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Chats",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "CarosBold",
            fontWeight: FontWeight.w600,
            fontSize: 28.sp,
          ),
        ),
        actions: [
          FutureBuilder<String>(
            future: _getFirstLetter(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircleAvatar(
                  radius: 30.r,
                  backgroundColor: Colors.black,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 1),
                    ),
                  ),
                );
              }
              return CircleAvatar(
                radius: 30.r,
                backgroundColor: Colors.black,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Text(
                      snapshot.data!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(top: 2.h),
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(35.r),
            topLeft: Radius.circular(35.r),
          ),
        ),
        child: BlocBuilder<ContactBloc, ContactState>(
          builder: (context, state) {
            if (state is ContactLoading) {
              return _buildShimmerList();
            } else if (state is ContactScreenLoaded) {
              final users = state.filteredUsers;

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomSearchTextField(
                            isSearch: true,
                            hintText: "Search here...",
                            onChanged: (query) {
                              context
                                  .read<ContactBloc>()
                                  .add(SearchContacts(query));
                            },
                          ),
                          SizedBox(height: 4.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 150.w),
                            child: Divider(
                              color: Colors.grey,
                              thickness: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  users.isEmpty
                      ? SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40.h),
                              child: const Text("No users yet"),
                            ),
                          ),
                        )
                      : SliverList.separated(
                          itemCount: users.length,
                          separatorBuilder: (_, __) => SizedBox(
                              height: orientation == Orientation.portrait
                                  ? 8.h
                                  : 9.h),
                          itemBuilder: (context, index) {
                            final user = users[index];
                            final chatId =
                                _getChatId(widget.currentUid, user.uid);
                            log(chatId);

                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection("chatRoom")
                                    .doc(chatId)
                                    .collection("messages")
                                    .orderBy("timeStamp", descending: true)
                                    // .limit(2)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    debugPrint(
                                        "🔄 Waiting for data from Firestore...");
                                  }

                                  if (snapshot.hasError) {
                                    log("❌ Firestore stream error: ${snapshot.error}");
                                  }

                                  if (snapshot.hasData) {
                                    log("✅ Stream received ${snapshot.data!.docs.length} docs");

                                    for (var doc in snapshot.data!.docs) {
                                      log("📄 Doc data: ${doc.data()}");
                                    }
                                  } else {
                                    log("⚠️ No data yet from stream");
                                  }
                                  MessageModel? latestMessage;
                                  int unreadCount = 0;
                                  if (snapshot.hasData &&
                                      snapshot.data!.docs.isNotEmpty) {
                                    debugPrint(snapshot.data.toString());
                                    final docs = snapshot.data!.docs;
                                    final first = docs.first.data()
                                        as Map<String, dynamic>;
                                    // final data = snapshot.data!.docs.first
                                    //     .data() as Map<String, dynamic>;
                                    latestMessage = MessageModel.fromMap(first);

                                    unreadCount = docs
                                        .where((d) =>
                                            d['isRead'] == false &&
                                            d['recieverId'] ==
                                                widget.currentUid)
                                        .length;
                                    log("Count is: ${unreadCount.toString()}");
                                  }

                                  return ChatTile(
                                      index: index,
                                      user: user,
                                      onTap: () async {
                                        final currentUserDoc =
                                            await FirebaseFirestore.instance
                                                .collection("users")
                                                .doc(widget.currentUid)
                                                .get();

                                        final currentUser = Usermodel.fromMap(
                                            currentUserDoc.data()!);

                                        Navigator.pushNamed(
                                          context,
                                          chatRoom,
                                          arguments: {
                                            "currentUser": currentUser,
                                            "receiver": user,
                                          },
                                        );
                                      },
                                      unreadCount: unreadCount,
                                      message: latestMessage);
                                  // ChatTile(
                                  //   unreadCount: unreadCount,
                                  //   index: index,
                                  //   user: user,
                                  //   message: latestMessage,
                                  //   onTap: () async {
                                  //     final currentUserDoc =
                                  //         await FirebaseFirestore.instance
                                  //             .collection("users")
                                  //             .doc(widget.currentUid)
                                  //             .get();

                                  //     final currentUser = Usermodel.fromMap(
                                  //         currentUserDoc.data()!);

                                  //     Navigator.pushNamed(
                                  //       context,
                                  //       chatRoom,
                                  //       arguments: {
                                  //         "currentUser": currentUser,
                                  //         "receiver": user,
                                  //       },
                                  //     );
                                  //   },
                                  // );
                                },
                              ),
                            );
                          },
                        ),
                ],
              );
            } else if (state is ContactError) {
              return Center(child: Text("Error: ${state.message}"));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

Widget _buildShimmerList() {
  return CustomScrollView(
    slivers: [
      SliverList.builder(
        itemCount: 6,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              leading: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              title: Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              subtitle: Container(
                margin: const EdgeInsets.only(top: 8),
                height: 10,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class ChatTile extends StatelessWidget {
  final Usermodel user;
  final MessageModel? message;
  final int index;
  final int unreadCount;
  final void Function()? onTap;

  const ChatTile({
    super.key,
    required this.index,
    required this.user,
    required this.onTap,
    required this.unreadCount,
    required this.message,
  });

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return "just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} h ago";
    if (diff.inDays == 1) return "Yesterday";
    return "${time.day}/${time.month}/${time.year}";
  }
  // final orientation = MediaQuery.of(context).orientation;

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        height: orientation == Orientation.portrait ? 70.h : null,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Row(
          children: [
            /// --- Avatar ---
            CircleAvatar(
              backgroundColor: grey.withAlpha(30),
              radius: orientation == Orientation.portrait ? 29.r : 30.r,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : "?",
                style: h.copyWith(color: primary, fontSize: 20.sp),
              ),
            ),
            SizedBox(width: 14.w),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: "Caros",
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontSize:
                          orientation == Orientation.portrait ? 15.sp : 17.sp,
                    ),
                  ),
                  SizedBox(
                      height: orientation == Orientation.portrait ? 2.h : 2.h),
                  Text(
                    message?.content ?? "No messages yet",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600],
                      // fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),

            /// --- Time and unread badge ---
            SizedBox(
              // width: 55.w,
              // height: 40.h,
              height: orientation == Orientation.portrait ? 44.h : 24.h,

              child: Column(
                mainAxisAlignment: unreadCount > 0
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Timestamp
                  if (message?.timeStamp != null)
                    Text(
                      _formatTime(message!.timeStamp!),
                      style:
                          TextStyle(color: Colors.grey[500], fontSize: 11.sp),
                    )
                  else
                    const SizedBox(),
                  unreadCount > 0
                      ? CircleAvatar(
                          radius: 11.r,
                          backgroundColor: Colors.red,
                          child: Center(
                            child: Text(
                              unreadCount.toString(),
                              style: small.copyWith(
                                color: Colors.white,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(height: 22),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
