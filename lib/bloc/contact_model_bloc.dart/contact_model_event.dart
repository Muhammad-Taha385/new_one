import 'package:equatable/equatable.dart';

abstract class ContactEvent extends Equatable {
  const ContactEvent();

  @override
  List<Object?> get props => [];
}

/// Load incoming requests
class LoadIncomingRequests extends ContactEvent {
  final String userId;
  const LoadIncomingRequests(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Load outgoing requests
class LoadOutgoingRequests extends ContactEvent {
  final String userId;
  const LoadOutgoingRequests(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Load accepted contacts
class LoadContacts extends ContactEvent {
  final String userId;
  const LoadContacts(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadfriendsContacts extends ContactEvent {
  final String currentUid;
  const LoadfriendsContacts(this.currentUid);

  @override
  List<Object?> get props => [currentUid];
}

/// Send a request
class SendFriendRequest extends ContactEvent {
  final String fromUid;
  final String toUid;
  const SendFriendRequest(this.fromUid, this.toUid);

  @override
  List<Object?> get props => [fromUid, toUid];
}

/// Accept a request
class AcceptFriendRequest extends ContactEvent {
  final String currentUid;
  final String targetUid;
  const AcceptFriendRequest(this.currentUid, this.targetUid);

  @override
  List<Object?> get props => [currentUid, targetUid];
}

/// Remove (reject or unfriend)
class RemoveContact extends ContactEvent {
  final String currentUid;
  final String targetUid;
  const RemoveContact(this.currentUid, this.targetUid);

  @override
  List<Object?> get props => [currentUid, targetUid];
}

class SearchContacts extends ContactEvent {
  final String query;
  // final bool isSearch;
  const SearchContacts(this.query,);
  @override
  List<Object?> get props => [query];

}
