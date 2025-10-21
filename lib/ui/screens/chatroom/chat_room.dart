import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import 'package:real_time_chat_application/bloc/chat_room_bloc/chat_room_bloc.dart';
import 'package:real_time_chat_application/bloc/chat_room_bloc/chat_room_event.dart';
import 'package:real_time_chat_application/bloc/chat_room_bloc/chat_room_state.dart';
import 'package:real_time_chat_application/core/constants/colors.dart';
import 'package:real_time_chat_application/core/constants/strings.dart';
import 'package:real_time_chat_application/core/constants/styles.dart';
import 'package:real_time_chat_application/core/models/message_model.dart';
import 'package:real_time_chat_application/core/models/usermodel.dart';
// import 'package:real_time_chat_application/core/services/call_screen.dart';
import 'package:real_time_chat_application/core/services/chat_Screen.dart';
import 'package:real_time_chat_application/ui/Widgets/TextField/svg_image.dart';
import 'package:real_time_chat_application/ui/Widgets/TextField/textfield.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
// import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
// import 'package:zego_uiki/zego_uiki.dart';

class ChatRoom extends StatefulWidget {
  final Usermodel currentUser;
  final Usermodel receiver;

  const ChatRoom({
    super.key,
    required this.currentUser,
    required this.receiver,
  });

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  @override
  Widget build(BuildContext context) {
    // final bloc = context.read<ChatRoomBloc>();
    // bloc.add(MarkMessagesRead(currentUser.uid));
    return BlocProvider(
      create: (_) =>
          ChatRoomBloc(ChatService(), widget.currentUser, widget.receiver),
      child: BlocBuilder<ChatRoomBloc, ChatRoomState>(
        builder: (context, state) {
          final bloc = context.read<ChatRoomBloc>();

          WidgetsBinding.instance.addPostFrameCallback((_) {
            bloc.add(MarkMessagesRead(widget.currentUser.uid));
          });
          // final messageController = TextEditingController();

          return Scaffold(
            body: Column(
              children: [
                /// Header
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 1.sw * 0.01,
                    vertical: 1.sh * 0.05,
                  ),
                  child: _Header(
                    name: widget.receiver.name, user: widget.receiver,
                    // } ,
                  ),
                ),

                /// Messages list
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                          // reverse: true,
                          controller: bloc.scrollController,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          itemCount: state.messages.length,
                          separatorBuilder: (_, __) => SizedBox(height: 10.h),
                          itemBuilder: (context, index) {
                            final message = state.messages[index];
                            return ChatBubble(
                              isCurrentUser:
                                  message.senderId == widget.currentUser.uid,
                              message: message,
                            );
                          },
                        ),
                ),

                /// Bottom input field
                BottomField(
                  controller: bloc.messageController,
                  onTap: () {
                    if (bloc.messageController.text.trim().isNotEmpty) {
                      bloc.add(SendMessage(bloc.messageController.text.trim()));
                      bloc.messageController.clear();
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Chat bubble widget
class ChatBubble extends StatelessWidget {
  final bool isCurrentUser;
  final MessageModel message;

  const ChatBubble({
    super.key,
    required this.isCurrentUser,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final alignment =
        // isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
        isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: 1.sw * 0.7, minWidth: 50.w),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isCurrentUser ? loginScreenLabelColor : grey.withAlpha(10),
            borderRadius: isCurrentUser
                ? BorderRadius.only(
                    topLeft: Radius.circular(15.r),
                    // topRight: Radius.circular(15.r),
                    bottomLeft: Radius.circular(15.r),
                    bottomRight: Radius.circular(15.r))
                : BorderRadius.only(
                    // topLeft: Radius.circular(15.r),
                    topRight: Radius.circular(15.r),
                    bottomRight: Radius.circular(15.r),
                    bottomLeft: Radius.circular(15.r)),
          ),
          child: Text(
            message.content ?? '',
            style: body.copyWith(
              color: isCurrentUser ? Colors.white : null,
              fontSize: 15,
            ),
          ),
        ),
        SizedBox(
          height: 4.h,
        ),
        Text(
          message.timeStamp != null
              ? DateFormat('hh:mm a').format(message.timeStamp!)
              : '',
          style: body.copyWith(
            color: isCurrentUser ? Colors.grey.shade900 : null,
            fontSize: 10,
            fontWeight: FontWeight.w100,
          ),
        ),
        if (isCurrentUser)
          Icon(
            (message.isRead ?? false) ? Icons.done_all : Icons.done,
            size: 14,
            color: (message.isRead ?? false) ? Colors.blue : Colors.grey,
          )
      ],
    );
  }
}

/// Bottom input field
class BottomField extends StatelessWidget {
  final void Function()? onTap;
  final void Function(String)? onChanged;
  final TextEditingController controller;

  const BottomField({
    super.key,
    this.onTap,
    this.onChanged,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: 1.sw * 0.05,
        vertical: 1.sh * 0.02,
      ),
      child: Row(
        children: [
          // CircleAvatar(
          //   radius: 20.r,
          //   backgroundColor: Colors.white,
          //   child: Icon(Icons.add, color: primary),
          // ),
          InkWell(
            child: SvgPics(
              image: clipIcon,
              height: 25.h,
              width: 25.w,
              fit: BoxFit.cover,
              semanticsLabel: "clipIcon",
            ),
          ),
          SizedBox(width: 8.w),

          /// Textfield
          Expanded(
            child: CustomTextField(
              filled: true,
              fillColor: grey.withAlpha(30),
              isChat: true,
              hintText: "Write your message",
              onChanged: onChanged,
              controller: controller,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.r),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.r),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.r),
                  borderSide: BorderSide.none),
            ),
          ),

          SizedBox(width: 4.w),

          /// Send button (only visible if text exists)
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              final hasText = value.text.trim().isNotEmpty;
              return hasText
                  ? InkWell(
                      onTap: onTap,
                      child: CircleAvatar(
                        radius: 21.r,
                        backgroundColor: loginScreenLabelColor,
                        child: SvgPics(
                          image: sendIcon,
                          height: 25.h,
                          width: 25.w,
                          fit: BoxFit.fill,
                          semanticsLabel: "sendIcon",
                        ),
                      ),
                      // Icon(Icons.send, color: primary),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPics(
                          image: cameraIcon,
                          height: 25.h,
                          width: 25.w,
                          fit: BoxFit.cover,
                          semanticsLabel: "cameraIcon",
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        SvgPics(
                          image: microphoneIcon,
                          height: 25.h,
                          width: 25.w,
                          fit: BoxFit.cover,
                          semanticsLabel: "microphoneIcon",
                        )
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }
}

/// Header
class _Header extends StatelessWidget {
  final Usermodel user;
  final String name;
  const _Header({required this.name, required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        SizedBox(width: 6.w),
        CircleAvatar(
          backgroundColor: grey.withAlpha(30),
          radius: 18.r,
          child: Text(
            user.name.isNotEmpty ? user.name[0] : "?",
            style: h.copyWith(fontSize: 18.sp, fontFamily: "Caros"),
          ),
        ),
        SizedBox(width: 7.w),
        Text(name, style: h.copyWith(fontSize: 18.sp, fontFamily: "Caros")),
        const Spacer(),
        ZegoSendCallInvitationButton(
          margin: EdgeInsets.all(0),
          padding: EdgeInsets.all(0),
          unclickableBackgroundColor: Colors.orange,
          // clickableBackgroundColor: Colors.red,
          // iconSize: Size(10, 20),

          isVideoCall: false,
          buttonSize: Size(40, 40),
          resourceID: "",
          invitees: [
            ZegoUIKitUser(id: user.uid, name: user.name),
          ],
          icon: ButtonIcon(
            icon: Icon(Icons.call, color: Colors.black, size: 22.h),
            backgroundColor: Colors.transparent,
          ),
        ),
        SizedBox(
          width: 2.w,
        ),
        ZegoSendCallInvitationButton(
          margin: EdgeInsets.all(0),
          padding: EdgeInsets.all(0),
          unclickableBackgroundColor: Colors.orange,
          // clickableBackgroundColor: Colors.red,
          // iconSize: Size(10, 20),

          isVideoCall: true,
          buttonSize: Size(40, 40),
          resourceID: "",
          invitees: [
            ZegoUIKitUser(id: user.uid, name: user.name),
          ],
          icon: ButtonIcon(
            icon: Icon(Icons.video_call, color: Colors.black, size: 22.h),
            backgroundColor: Colors.transparent,
          ),
        ),
        SizedBox(
          width: 4.w,
        )
      ],
    );
  }
}
