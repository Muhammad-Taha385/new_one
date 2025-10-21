import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_time_chat_application/bloc/chat_room_bloc/chat_room_event.dart';
import 'package:real_time_chat_application/bloc/chat_room_bloc/chat_room_state.dart';
import 'package:real_time_chat_application/core/models/message_model.dart';
import 'package:real_time_chat_application/core/models/usermodel.dart';
import 'package:real_time_chat_application/core/services/chat_Screen.dart';

class ChatRoomBloc extends Bloc<ChatRoomEvent, ChatRoomState> {
  final ChatService _chatService;
  final Usermodel currentUser;
  final Usermodel receiver;

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  StreamSubscription? _subscription;
  late final String chatRoomId;

  ChatRoomBloc(this._chatService, this.currentUser, this.receiver)
      : super(const ChatRoomState()) {
    _setupChatRoomId();

    on<LoadMessages>(_onLoadMessages);
    on<MessagesUpdated>(_onMessagesUpdated);
    on<SendMessage>(_onSendMessage);
    on<MarkMessagesRead>(_onMarkMessagesRead); // ✅ fixed here

//     on<MarkMessagesRead>((event, emit) {
//     final updatedMessages = state.messages.map((message) {
//     if (message.recieverId == event.currentUserId && !message.isRead!) {
//       return MessageModel(
//         senderId: message.senderId,
//         recieverId: message.recieverId,
//         content: message.content,
//         timeStamp: message.timeStamp,
//         isRead: true,
//       );
//     }
//     return message;
//   }).toList();

//   emit(state.copyWith(messages: updatedMessages));
// });

    add(LoadMessages(chatRoomId));
  }

  // void _setupChatRoomId() {
  //   if (currentUser.uid.hashCode > receiver.uid.hashCode) {
  //     chatRoomId = "${currentUser.uid}_${receiver.uid}";
  //   } else {
  //     chatRoomId = "${receiver.uid}_${currentUser.uid}";
  //   }
  // }
  void _setupChatRoomId() {
  final sorted = [currentUser.uid, receiver.uid]..sort();
  chatRoomId = "${sorted.first}_${sorted.last}";
}


  Future<void> _onLoadMessages(
      LoadMessages event, Emitter<ChatRoomState> emit) async {
    emit(state.copyWith(isLoading: true));
    _subscription =
        _chatService.getMessage(event.chatRoomId).listen((snapshot) {
      final msgs =
          snapshot.docs.map((e) => MessageModel.fromMap(e.data())).toList();
      add(MessagesUpdated(msgs));
    });
  }

  void _onMessagesUpdated(MessagesUpdated event, Emitter<ChatRoomState> emit) {
    final wasEmpty = state.messages.isEmpty;

    emit(state.copyWith(messages: event.messages, isLoading: false));
    WidgetsBinding.instance.addPostFrameCallback((_) {
    if (scrollController.hasClients) {
      if (wasEmpty) {
        // First time loading chat — jump instantly (no animation)
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      } 
      else {
        //   // New message arrived — smooth scroll
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
          );
        }
      // else {
        // New message received — keep scroll behavior normal (optional)
      // }
    }
  });
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (scrollController.hasClients) {
    //     // if (wasEmpty) {
    //     // Opening chat first time — jump instantly
    //     scrollController.jumpTo(scrollController.position.maxScrollExtent);
    //     // }
    //     // else {
    //     //   // New message arrived — smooth scroll
    //     //   // scrollController.animateTo(
    //     //   //   scrollController.position.maxScrollExtent,
    //     //   //   duration: const Duration(milliseconds: 100),
    //     //   //   curve: Curves.easeOut,
    //     //   // );
    //     // }
    //   }
    // });
  }

  Future<void> _onSendMessage(
      SendMessage event, Emitter<ChatRoomState> emit) async {
    final now = DateTime.now();
    final msg = MessageModel(
        timeStamp: now,
        id: now.microsecondsSinceEpoch.toString(),
        senderId: currentUser.uid,
        recieverId: receiver.uid,
        content: event.content,
        isRead: false);

    await _chatService.saveMessage(msg.toMap(), chatRoomId);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }
//     Future<void> _onSendMessage(
//       SendMessage event, Emitter<ChatRoomState> emit) async {
//     final now = DateTime.now();
// final msg = MessageModel(
//   timeStamp: DateTime.now(),
//   id: now.microsecondsSinceEpoch.toString(),
//   senderId: currentUser.uid,
//   recieverId: receiver.uid,
//   content: event.content,
//   isRead: false,
// );

// await _chatService.saveMessage(msg.toMap(), chatRoomId);

//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (scrollController.hasClients) {
//         scrollController.animateTo(
//           scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 100),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

  Future<void> _onMarkMessagesRead(
      MarkMessagesRead event, Emitter<ChatRoomState> emit) async {
    try {
      final unreadMessages = await FirebaseFirestore.instance
          .collection("chatRoom")
          .doc(chatRoomId)
          .collection("messages")
          .where("recieverId", isEqualTo: event.currentUserId)
          .where("isRead", isEqualTo: false)
          .get();

      for (var doc in unreadMessages.docs) {
        await doc.reference.update({"isRead": true});
      }

      // Update local UI state immediately
      final updatedMessages = state.messages.map((message) {
        if (message.recieverId == event.currentUserId &&
            (message.isRead ?? false) == false) {
          return MessageModel(
            id: message.id,
            senderId: message.senderId,
            recieverId: message.recieverId,
            content: message.content,
            timeStamp: message.timeStamp,
            isRead: true,
          );
        }
        return message;
      }).toList();

      emit(state.copyWith(messages: updatedMessages));
    } catch (e) {
      debugPrint("Error marking messages as read: $e");
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    messageController.dispose();
    scrollController.dispose();
    return super.close();
  }
}
