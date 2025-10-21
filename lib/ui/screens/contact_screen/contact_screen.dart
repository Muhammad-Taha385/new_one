// import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// ❌ Remove this import, not needed here
// import 'package:real_time_chat_application/bloc/chat_screen_bloc/chat_screen_event.dart';

import 'package:real_time_chat_application/bloc/contact_model_bloc.dart/contact_model_bloc.dart';
import 'package:real_time_chat_application/bloc/contact_model_bloc.dart/contact_model_event.dart';
import 'package:real_time_chat_application/bloc/contact_model_bloc.dart/contact_model_state.dart';
import 'package:real_time_chat_application/core/constants/colors.dart';
import 'package:real_time_chat_application/core/models/usermodel.dart';
import 'package:real_time_chat_application/core/services/database_service.dart';

class ContactScreen extends StatefulWidget {
  final String currentUserId;

  const ContactScreen({super.key, required this.currentUserId});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ContactBloc _contactBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _contactBloc = ContactBloc(DatabaseService());

    // Load contacts by default
    _contactBloc.add(LoadContacts(widget.currentUserId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _contactBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _contactBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Contacts"),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "Contacts"),
              Tab(text: "Incoming"),
              // Tab(text: "Outgoing"),
            ],
            onTap: (index) {
              if (index == 0) {
                _contactBloc.add(LoadContacts(widget.currentUserId));
              } else if (index == 1) {
                _contactBloc.add(LoadIncomingRequests(widget.currentUserId));
              } 
              // else {
              //   _contactBloc.add(LoadOutgoingRequests(widget.currentUserId));
              // }
            },
          ),
        ),
        body: BlocBuilder<ContactBloc, ContactState>(
          builder: (context, state) {
            if (state is ContactLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ContactsLoaded) {
              return _buildUserList(state.contacts, isContact: true);
            } else if (state is IncomingRequestsLoaded) {
              return _buildUserList(state.incoming, isIncoming: true);
            // } else if (state is OutgoingRequestsLoaded) {
            //   return _buildUserList(state.outgoing, isOutgoing: true);
            } else if (state is ContactError) {
              return Center(child: Text(state.message));
            } else if (state is ContactSuccess) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text("No data"));
          },
        ),
      ),
    );
  }

  Widget _buildUserList(
    List<Usermodel> users, {
    bool isContact = false,
    bool isIncoming = false,
    // bool isOutgoing = false,
  }) {
    if (users.isEmpty) {
      return const Center(child: Text("No users found"));
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user.profileImageUrl),
          ),
          title: Text(user.name),
          subtitle: Text(user.email),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isIncoming) ...[
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () {
                    _contactBloc.add(
                      AcceptFriendRequest(widget.currentUserId, user.uid),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    _contactBloc.add(
                      RemoveContact(widget.currentUserId, user.uid),
                    );
                  },
                ),
              ],
              // if (isOutgoing) ...[
              //   const Text("Pending"),
              //   IconButton(
              //     icon: const Icon(Icons.cancel, color: Colors.red),
              //     onPressed: () {
              //       _contactBloc.add(
              //         RemoveContact(widget.currentUserId, user.uid),
              //       );
              //     },
              //   ),
              // ],
              if (isContact) ...[
                // IconButton(
                //   icon: const Icon(Icons.message, color: Colors.blue),
                //   onPressed: () {
                //     // 👉 Navigate to chat screen
                //     Navigator.pushNamed(context, chatRoom);
                //   },
                // ),
isContactContainer(
                onTap: () {
                  if (user.requestStatus == "none") {
                    context.read<ContactBloc>().add(
                          SendFriendRequest(
                            widget.currentUserId,
                            user.uid,
                          ),
                        );
                  }
                },
                text: user.requestStatus == "pending"
                    ? "Pending"
                    : user.requestStatus == "accepted"
                        ? "Friends"
                        : "Add",
                color: primary,
                textColor: Colors.white,
                truewidth: 54.w,
                trueheight: 23.h,
                height: 20.h,
                width: 50.w,
                istrue: user.requestStatus == "pending" ||
                        user.requestStatus == "accepted",
              ),
                // IconButton(
                //   icon: const Icon(Icons.add_circle, color: Colors.black),
                //   onPressed: () {
                //     _contactBloc.add(
                //         // RemoveContact(widget.currentUserId, user.uid) ,
                //         SendFriendRequest(widget.currentUserId, user.uid));
                //   },
                // ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class isContactContainer extends StatelessWidget {
  final bool istrue;
  final String text;
  final Color? color;
  final Color? textColor;
  final double? height;
  final double? width;
  final double? trueheight;
  final double? truewidth;
  final void Function()? onTap;

  const isContactContainer({
    this.trueheight,
    this.truewidth,
    this.onTap,
    required this.istrue,
    this.height,
    this.width,
    this.textColor,
    this.color,
    required this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: istrue ? trueheight : height,
        width: istrue ? truewidth : width,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }
}

