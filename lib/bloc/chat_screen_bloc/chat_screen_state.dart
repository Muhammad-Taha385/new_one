import 'package:real_time_chat_application/core/models/usermodel.dart';

abstract class ChatScreenState {}

class ChatScreenInitial extends ChatScreenState {}

class ChatScreenLoading extends ChatScreenState {}

class ChatScreenLoaded extends ChatScreenState {
  final List<Usermodel> users;
  final List<Usermodel> filteredUsers;

  ChatScreenLoaded(this.users, {String query = ""})
      : filteredUsers = query.isEmpty
            ? users
            : users
                .where((u) => u.name.toLowerCase().contains(query.toLowerCase()))
                .toList();
}

class ChatScreenError extends ChatScreenState {
  final String message;
  ChatScreenError(this.message);
}
