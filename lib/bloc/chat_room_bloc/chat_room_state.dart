
import 'package:equatable/equatable.dart';
import 'package:real_time_chat_application/core/models/message_model.dart';

class ChatRoomState extends Equatable {
  final List<MessageModel> messages;
  final bool isLoading;
  final String? error;

  const ChatRoomState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatRoomState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatRoomState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [messages, isLoading, error];
}
