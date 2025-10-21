
import 'package:equatable/equatable.dart';
import 'package:real_time_chat_application/core/models/usermodel.dart';

abstract class ContactState extends Equatable {
  const ContactState();

  @override
  List<Object?> get props => [];
}

class ContactInitial extends ContactState {}

class ContactLoading extends ContactState {}

class ContactsLoaded extends ContactState {
  final List<Usermodel> contacts; // Changed
  const ContactsLoaded(this.contacts);

  @override
  List<Object?> get props => [contacts];
}

class IncomingRequestsLoaded extends ContactState {
  final List<Usermodel> incoming;
  const IncomingRequestsLoaded(this.incoming);

  @override
  List<Object?> get props => [incoming];
}

class OutgoingRequestsLoaded extends ContactState {
  final List<Usermodel> outgoing;
  const OutgoingRequestsLoaded(this.outgoing);

  @override
  List<Object?> get props => [outgoing];
}

class ContactSuccess extends ContactState {
  final String message;
  const ContactSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ContactScreenLoaded extends ContactState {
  final List<Usermodel> users;
  final List<Usermodel> filteredUsers;
  final String query;
  // bool isSearch = false;

  ContactScreenLoaded(this.users, {this.query = ""})
      : filteredUsers = query.isEmpty
            ? users
            : users
                .where((u) =>
                    u.name.toLowerCase().contains(query.toLowerCase()))
                .toList();
  @override
  List<Object?> get props => [users, filteredUsers ,query];
}

class ContactError extends ContactState {
  final String message;
  const ContactError(this.message);

  @override
  List<Object?> get props => [message];
}
