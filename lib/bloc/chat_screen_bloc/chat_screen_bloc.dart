import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_time_chat_application/bloc/chat_screen_bloc/chat_screen_event.dart';
import 'package:real_time_chat_application/bloc/chat_screen_bloc/chat_screen_state.dart';
import 'package:real_time_chat_application/core/models/usermodel.dart';
import 'package:real_time_chat_application/core/services/database_service.dart';

class ChatScreenBloc extends Bloc<ChatScreenEvent, ChatScreenState> {
  final DatabaseService _db;

  ChatScreenBloc(this._db) : super(ChatScreenInitial()) {
    on<LoadContacts>(_onLoadContacts);
    on<RemoveContact>(_onRemoveContact);
    on<SearchContacts>(_onSearchContacts);
  }

  Future<void> _onLoadContacts(
      LoadContacts event, Emitter<ChatScreenState> emit) async {
    emit(ChatScreenLoading());
    try {
      final users = await _db.fetchUser(event.currentUid);
      final userModels = users.map((e) => Usermodel.fromMap(e!)).toList();
      emit(ChatScreenLoaded(userModels));
    } catch (e) {
      emit(ChatScreenError("Failed to load contacts: $e"));
    }
  }

  Future<void> _onRemoveContact(
      RemoveContact event, Emitter<ChatScreenState> emit) async {
    try {
      await _db.removeContact(event.currentUid, event.contactUid);
      add(LoadContacts(event.currentUid));
    } catch (e) {
      emit(ChatScreenError("Failed to remove: $e"));
    }
  }

  void _onSearchContacts(
      SearchContacts event, Emitter<ChatScreenState> emit) {
    if (state is ChatScreenLoaded) {
      final currentState = state as ChatScreenLoaded;
      emit(ChatScreenLoaded(currentState.users, query: event.query));
    }
  }
}
