// import 'dart:async';
// import 'dart:math';

import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_time_chat_application/bloc/contact_model_bloc.dart/contact_model_event.dart';
import 'package:real_time_chat_application/bloc/contact_model_bloc.dart/contact_model_state.dart';
// import 'package:real_time_chat_application/core/models/usermodel.dart';
import 'package:real_time_chat_application/core/services/database_service.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final DatabaseService dbService;
  // bool isSearch = false;
  //  StreamSubscription? _contactsSub;

  ContactBloc(this.dbService) : super(ContactInitial()) {
    on<LoadIncomingRequests>(_onLoadIncoming);
    on<LoadOutgoingRequests>(_onLoadOutgoing);
    on<LoadContacts>(_onLoadContacts);
    on<LoadfriendsContacts>(_onLoadfriendsContacts);
    on<SendFriendRequest>(_onSendRequest);
    on<AcceptFriendRequest>(_onAcceptRequest);
    on<RemoveContact>(_onRemoveContact);
    on<SearchContacts>(_onSearchContacts);
  }

  void _onSearchContacts(SearchContacts event, Emitter<ContactState> emit) async{
    // currentState.isSearch = isSearch;

    if (state is ContactScreenLoaded) {
      log("SearchLoading");
      final currentState = state as ContactScreenLoaded;
      log("Query Loading");
      await Future.delayed(const Duration(milliseconds: 500));
      emit(ContactScreenLoaded(currentState.users, query: event.query));
      log("SearchLoaded");
    }
    // emit(ContactScreenLoaded(currentState.users, query: event.query));
    // isSearch = true;
    // currentState.isSearch = isSearch;
  }

  Future<void> _onLoadIncoming(
      LoadIncomingRequests event, Emitter<ContactState> emit) async {
    emit(ContactLoading());
    try {
      final incoming = await dbService.fetchIncomingRequests(event.userId);
      emit(IncomingRequestsLoaded(incoming));
    } catch (e) {
      emit(ContactError("❌ Failed to load incoming requests: $e"));
    }
  }

  Future<void> _onLoadOutgoing(
      LoadOutgoingRequests event, Emitter<ContactState> emit) async {
    emit(ContactLoading());
    try {
      final outgoing = await dbService.fetchOutgoingRequests(event.userId);
      emit(OutgoingRequestsLoaded(outgoing));
    } catch (e) {
      emit(ContactError("❌ Failed to load outgoing requests: $e"));
    }
  }

  // Future<void> _onLoadContacts(
  //     LoadContacts event, Emitter<ContactState> emit) async {
  //   emit(ContactLoading());
  //   try {
  //     final contacts = await dbService.fetchContacts(event.userId);
  //     // final contacts = await dbService.fetchUser(event.userId);

  //     emit(ContactsLoaded(contacts));
  //   } catch (e) {
  //     emit(ContactError("❌ Failed to load contacts: $e"));
  //   }
  // }

  Future<void> _onSendRequest(
      SendFriendRequest event, Emitter<ContactState> emit) async {
    try {
      await dbService.sendFriendRequest(event.fromUid, event.toUid);
      emit(ContactSuccess("📩 Request sent"));
      add(LoadContacts(event.fromUid)); // refresh outgoing
    } catch (e) {
      emit(ContactError("❌ Failed to send request: $e"));
    }
  }

  Future<void> _onAcceptRequest(
      AcceptFriendRequest event, Emitter<ContactState> emit) async {
    try {
      await dbService.acceptContactRequest(event.currentUid, event.targetUid);
      // emit(ContactSuccess("✅ Request accepted"));
      // emit()
      final incoming = await dbService.fetchIncomingRequests(event.currentUid);
      emit(IncomingRequestsLoaded(incoming));
      // add(LoadContacts(event.currentUid)); // refresh contacts
    } catch (e) {
      emit(ContactError("Failed to accept request: $e"));
    }
  }

  Future<void> _onRemoveContact(
      RemoveContact event, Emitter<ContactState> emit) async {
    try {
      await dbService.removeContact(event.currentUid, event.targetUid);
      emit(ContactSuccess("Contact removed"));
      add(LoadContacts(event.currentUid)); // refresh contacts
    } catch (e) {
      emit(ContactError("Failed to remove contact: $e"));
    }
  }

  Future<void> _onLoadContacts(
      LoadContacts event, Emitter<ContactState> emit) async {
    emit(ContactLoading());
    try {
      final contacts = await dbService.loadContactsWithStatus(event.userId);
      emit(ContactsLoaded(contacts));
    } catch (e) {
      emit(ContactError("Failed to load contacts: $e"));
    }
  }
  // bool _hasLoadedFriends = false;

//  StreamSubscription? _contactsSub;
  Future<void> _onLoadfriendsContacts(
    LoadfriendsContacts event,
    Emitter<ContactState> emit,
  ) async {
    if (state is ContactScreenLoaded) return; // ✅ Already loaded once, skip reload

    // if(_hasLoadedFriends) return;
    // _hasLoadedFriends = true;
    // await Future.delayed(Duration(seconds: 5));
    emit(ContactLoading());
    try {
      final users = await dbService.fetchfriendsContacts(event.currentUid);
      emit(ContactScreenLoaded(users));
    } catch (e) {
      emit(ContactError("Failed to load contacts: $e"));
    }
  }

// Future<void> _onLoadfriendsContacts(
//     LoadfriendsContacts event, Emitter<ContactState> emit) async {
//   emit(ContactLoading());
//   // _contactsSub?.cancel(); // cancel previous if reloading

//   _contactsSub = dbService
//       .streamFriendsContacts(event.currentUid)
//       .listen((users) {
//         emit(ContactScreenLoaded(users));
//       }, onError: (e) {
//         emit(ContactError("Failed to load contacts: $e"));
//       });
// }

  @override
  Future<void> close() {
    // _contactsSub?.cancel();
    return super.close();
  }
}
