// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:real_time_chat_application/bloc/user_provider/user_provider_bloc.dart';
// import 'package:real_time_chat_application/bloc/user_provider/user_provider_event.dart';
// import 'package:real_time_chat_application/bloc/user_provider/user_provider_state.dart';
// import 'package:real_time_chat_application/ui/screens/bottom_navigation_bar/bottom_navigation_bar.dart';
// import 'package:real_time_chat_application/ui/screens/onBoardingScreen/onBoradingScreen.dart';
// import 'package:real_time_chat_application/practice/webrtc_callscreen.dart';

// class UserSessionHandling extends StatefulWidget {
//   const UserSessionHandling({super.key});

//   @override
//   State<UserSessionHandling> createState() => _UserSessionHandlingState();
// }

// class _UserSessionHandlingState extends State<UserSessionHandling> {
//   bool _isListenerAttached = false;
//   StreamSubscription<DocumentSnapshot>? _callSub;

//   @override
//   void initState() {
//     super.initState();

//     FirebaseAuth.instance.authStateChanges().listen((user) {
//       if (user != null && user.emailVerified) {
//         if (!_isListenerAttached) {
//           _listenForIncomingCalls(user.uid);
//           _isListenerAttached = true;
//         }
//       } else {
//         _callSub?.cancel();
//         _isListenerAttached = false;
//       }
//     });
//   }

//   void _listenForIncomingCalls(String currentUserId) {
//     _callSub = FirebaseFirestore.instance
//         .collection('users')
//         .doc(currentUserId)
//         .collection('incoming_call')
//         .doc('active')
//         .snapshots()
//         .listen((snapshot) {
//       if (snapshot.exists && snapshot.data() != null) {
//         final data = snapshot.data()!;
//         final roomId = data['roomId'];
//         final callerId = data['callerId'];

//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => WebRTCCallScreen(
//               currentUserId: currentUserId,
//               receiverId: callerId,
//               isCaller: false,
//               roomId: roomId,
//             ),
//           ),
//         );
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _callSub?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         final bloc = context.read<UserBloc>();

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final user = snapshot.data;

//         if (user != null && user.emailVerified) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             bloc.add(FetchUser(user.uid));
//           });

//           return BlocBuilder<UserBloc, UserState>(
//             builder: (context, state) {
//               if (state is UserLoaded) {
//                 return MyBottomNavigationBar();
//               } else if (state is UserError) {
//                 return Center(child: Text("Error: ${state.message}"));
//               } else {
//                 return const SizedBox();
//               }
//             },
//           );
//         } else {
//           bloc.add(ClearUser());
//           return const OnBoardingScreen();
//         }
//       },
//     );
//   }
// }
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_time_chat_application/bloc/user_provider/user_provider_bloc.dart';
import 'package:real_time_chat_application/bloc/user_provider/user_provider_event.dart';
import 'package:real_time_chat_application/bloc/user_provider/user_provider_state.dart';
import 'package:real_time_chat_application/practice/webrtc_incoming_call.dart';
import 'package:real_time_chat_application/ui/screens/bottom_navigation_bar/bottom_navigation_bar.dart';
import 'package:real_time_chat_application/ui/screens/onBoardingScreen/onBoradingScreen.dart';

class UserSessionHandling extends StatefulWidget {
  const UserSessionHandling({super.key});

  @override
  State<UserSessionHandling> createState() => _UserSessionHandlingState();
}

class _UserSessionHandlingState extends State<UserSessionHandling> {
  bool _isListenerAttached = false;
  StreamSubscription<DocumentSnapshot>? _callSub;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && user.emailVerified) {
        if (!_isListenerAttached) {
          _listenForIncomingCalls(user.uid);
          _isListenerAttached = true;
        }
      } else {
        _callSub?.cancel();
        _isListenerAttached = false;
      }
    });
  }

  void _listenForIncomingCalls(String currentUserId) {
    _callSub = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('incoming_call')
        .doc('active')
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;

      final data = snapshot.data();
      if (data == null) return;

      final roomId = data['roomId'];
      final callerId = data['callerId'];
      final status = data['status'];

      // Only navigate if not answered yet
      if (status == null) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => IncomingCallScreen(
                currentUserId: currentUserId,
                callerId: callerId,
                roomId: roomId,
              ),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _callSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final bloc = context.read<UserBloc>();

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;

        if (user != null && user.emailVerified) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            bloc.add(FetchUser(user.uid));
          });

          return BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              if (state is UserLoaded) {
                return const MyBottomNavigationBar();
              } else if (state is UserError) {
                return Center(child: Text("Error: ${state.message}"));
              } else {
                return const SizedBox();
              }
            },
          );
        } else {
          bloc.add(ClearUser());
          return const OnBoardingScreen();
        }
      },
    );
  }
}
