
import 'package:equatable/equatable.dart';
import 'package:real_time_chat_application/core/models/message_model.dart';

abstract class ChatRoomEvent extends Equatable {
  const ChatRoomEvent();

  @override
  List<Object?> get props => [];
}

class LoadMessages extends ChatRoomEvent {
  final String chatRoomId;
  const LoadMessages(this.chatRoomId);

  @override
  List<Object?> get props => [chatRoomId];
}

class MessagesUpdated extends ChatRoomEvent {
  final List<MessageModel> messages;
  const MessagesUpdated(this.messages);

  @override
  List<Object?> get props => [messages];
}

class SendMessage extends ChatRoomEvent {
  final String content;
  const SendMessage(this.content);

  @override
  List<Object?> get props => [content];
}

class MarkMessagesRead extends ChatRoomEvent {
  final String currentUserId;

  const MarkMessagesRead(this.currentUserId);
  @override
  List <Object?> get props => [currentUserId];
}

