// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:real_time_chat_application/practice/webrtc_callscreen.dart';

// class IncomingCallScreen extends StatelessWidget {
//   final String currentUserId;
//   final String callerId;
//   final String roomId;

//   const IncomingCallScreen({
//     super.key,
//     required this.currentUserId,
//     required this.callerId,
//     required this.roomId,
//   });

//   void _acceptCall(BuildContext context) async {
//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(currentUserId)
//         .collection('incoming_call')
//         .doc('active')
//         .update({'status': 'accepted'});

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (_) => WebRTCCallScreen(
//           currentUserId: currentUserId,
//           receiverId: callerId,
//           isCaller: false,
//           roomId: roomId,
//         ),
//       ),
//     );
//   }

//   void _rejectCall(BuildContext context) async {
//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(currentUserId)
//         .collection('incoming_call')
//         .doc('active')
//         .update({'status': 'rejected'});
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.videocam, size: 80, color: Colors.white),
//             const SizedBox(height: 30),
//             const Text(
//               "Incoming Call...",
//               style: TextStyle(color: Colors.white, fontSize: 22),
//             ),
//             const SizedBox(height: 40),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 FloatingActionButton(
//                   heroTag: 'webrtc_call_reject', // 👈 Add unique hero tag

//                   backgroundColor: Colors.red,
//                   onPressed: () => _rejectCall(context),
//                   child: const Icon(Icons.call_end),
//                 ),
//                 FloatingActionButton(
//                   heroTag: 'webrtc_call_accept', // 👈 Add unique hero tag
//                   backgroundColor: Colors.green,
//                   onPressed: () => _acceptCall(context),
//                   child: const Icon(Icons.call),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
