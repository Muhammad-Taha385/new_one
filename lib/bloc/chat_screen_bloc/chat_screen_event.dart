abstract class ChatScreenEvent {}

class LoadContacts extends ChatScreenEvent {
  final String currentUid;
  LoadContacts(this.currentUid);
}

class RemoveContact extends ChatScreenEvent {
  final String currentUid;
  final String contactUid;
  RemoveContact(this.currentUid, this.contactUid);
}

class SearchContacts extends ChatScreenEvent {
  final String query;
  SearchContacts(this.query);
}
