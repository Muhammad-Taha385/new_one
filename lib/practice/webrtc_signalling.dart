// import 'dart:developer';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';

// typedef StreamCallback = void Function(MediaStream stream);

// class Signaling {
//   RTCPeerConnection? _peerConnection;
//   MediaStream? _localStream;
//   StreamCallback? onAddRemoteStream;

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   final Map<String, dynamic> _iceServers = {
//     'iceServers': [
//       {'urls': 'stun:stun1.l.google.com:19302'},
//       {'urls': 'stun:stun.relay.metered.ca:80'},
//       {
//         'urls': 'turn:turn.relay.metered.ca:80',
//         'username': 'openrelayproject',
//         'credential': 'openrelayproject'
//       },
//     ]
//   };

//   /// 🔹 Open camera and mic
//   Future<void> openUserMedia(RTCVideoRenderer localRenderer) async {
//     final stream = await navigator.mediaDevices.getUserMedia({
//       'audio': true,
//       'video': true,
//     });
//     localRenderer.srcObject = stream;
//     _localStream = stream;
//   }

//   /// 🔹 Create Room (Caller)
//   Future<String> createRoom(String callerId, String receiverId) async {
//     _peerConnection = await createPeerConnection(_iceServers);
//     _registerPeerConnectionListeners();

//     // Add tracks from local stream
//     _localStream?.getTracks().forEach((track) {
//       _peerConnection?.addTrack(track, _localStream!);
//     });

//     final roomRef = _firestore.collection('rooms').doc();
//     final callerCandidates = roomRef.collection('callerCandidates');

//     _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
//       callerCandidates.add(candidate.toMap());
//     };

//     _peerConnection?.onAddStream = (stream) {
//       onAddRemoteStream?.call(stream);
//     };

//     final offer = await _peerConnection!.createOffer();
//     await _peerConnection!.setLocalDescription(offer);

//     await roomRef.set({
//       'offer': offer.toMap(),
//       'callerId': callerId,
//       'receiverId': receiverId,
//       'createdAt': FieldValue.serverTimestamp(),
//     });

//     // 🔔 Notify receiver of the incoming call
//     await _firestore
//         .collection('users')
//         .doc(receiverId)
//         .collection('incoming_call')
//         .doc('active')
//         .set({
//       'roomId': roomRef.id,
//       'callerId': callerId,
//       'isVideo': true,
//     });

//     log("Room created with ID: ${roomRef.id}");

//     // 🔹 Listen for remote answer
//     roomRef.snapshots().listen((snapshot) async {
//       final data = snapshot.data();
//       if (data != null && data['answer'] != null) {
//         final answer = data['answer'];
//         final remoteDesc = RTCSessionDescription(answer['sdp'], answer['type']);

//         // ✅ Use async getter for remote description
//         final currentRemote = await _peerConnection?.getRemoteDescription();
//         if (currentRemote == null) {
//           await _peerConnection?.setRemoteDescription(remoteDesc);
//           log("Remote description set from callee ✅");
//         }
//       }
//     });

//     // 🔹 Listen for callee ICE candidates
//     roomRef.collection('calleeCandidates').snapshots().listen((snapshot) {
//       for (var change in snapshot.docChanges) {
//         if (change.type == DocumentChangeType.added) {
//           final data = change.doc.data()!;
//           _peerConnection?.addCandidate(
//             RTCIceCandidate(
//               data['candidate'],
//               data['sdpMid'],
//               data['sdpMLineIndex'],
//             ),
//           );
//           log("Added remote ICE candidate from callee ✅");
//         }
//       }
//     });

//     return roomRef.id;
//   }

//   /// 🔹 Join Room (Callee)
//   Future<void> joinRoom(String roomId) async {
//     final roomRef = _firestore.collection('rooms').doc(roomId);
//     final snapshot = await roomRef.get();

//     if (!snapshot.exists) throw Exception("Room not found!");

//     _peerConnection = await createPeerConnection(_iceServers);
//     _registerPeerConnectionListeners();

//     _localStream?.getTracks().forEach((track) {
//       _peerConnection?.addTrack(track, _localStream!);
//     });

//     final calleeCandidates = roomRef.collection('calleeCandidates');

//     _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
//       calleeCandidates.add(candidate.toMap());
//     };

//     _peerConnection?.onAddStream = (stream) {
//       onAddRemoteStream?.call(stream);
//     };

//     final data = snapshot.data()!;
//     final offer = data['offer'];
//     await _peerConnection!.setRemoteDescription(
//       RTCSessionDescription(offer['sdp'], offer['type']),
//     );

//     final answer = await _peerConnection!.createAnswer();
//     await _peerConnection!.setLocalDescription(answer);

//     await roomRef.update({'answer': answer.toMap()});

//     // Listen for caller ICE candidates
//     roomRef.collection('callerCandidates').snapshots().listen((snapshot) {
//       for (var change in snapshot.docChanges) {
//         if (change.type == DocumentChangeType.added) {
//           final data = change.doc.data()!;
//           _peerConnection?.addCandidate(
//             RTCIceCandidate(
//               data['candidate'],
//               data['sdpMid'],
//               data['sdpMLineIndex'],
//             ),
//           );
//         }
//       }
//     });
//   }

//   void _registerPeerConnectionListeners() {
//     _peerConnection?.onConnectionState = (state) {
//       log("Connection State: $state");
//     };
//   }

//   /// 🔹 End call
//   Future<void> hangUp(String roomId, String receiverId) async {
//     await _localStream?.dispose();
//     await _peerConnection?.close();

//     await _firestore
//         .collection('users')
//         .doc(receiverId)
//         .collection('incoming_call')
//         .doc('active')
//         .delete()
//         .catchError((_) {});

//     _peerConnection = null;
//     _localStream = null;
//   }
// }
// webrtc_optimized.dart
// Single-file optimized WebRTC flow for Flutter using flutter_webrtc + Firestore
// Includes: Signaling, WebRTCCallScreen, IncomingCallScreen
// Improvements made:
// - Proper addTrack usage
// - Safe renderer disposal (avoid Android Surface crash)
// - Delete room + candidate subcollections on hangup
// - Remove incoming_call doc after accept/reject
// - Timeout for unanswered calls (default 45s)
// - Defensive null checks and error handling
// - Clear comments to adapt to your project












// import 'dart:async';
// import 'dart:developer';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:uuid/uuid.dart';

// typedef StreamCallback = void Function(MediaStream stream);

// class Signaling {
//   RTCPeerConnection? _peerConnection;
//   MediaStream? _localStream;
//   StreamCallback? onAddRemoteStream;

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   final Map<String, dynamic> _iceServers = {
//     'iceServers': [
//       {'urls': 'stun:stun1.l.google.com:19302'},
//       // Add your TURN servers here if you have them
//       // {
//       //   'urls': 'turn:your.turn.server:3478',
//       //   'username': 'user',
//       //   'credential': 'pass'
//       // }
//     ]
//   };

//   /// Open camera & mic and attach to localRenderer
//   Future<void> openUserMedia(RTCVideoRenderer localRenderer) async {
//     try {
//       final stream = await navigator.mediaDevices.getUserMedia({
//         'audio': true,
//         'video': {
//           'facingMode': 'user',
//         },
//       });
//       localRenderer.srcObject = stream;
//       _localStream = stream;
//     } catch (e) {
//       log('Failed to getUserMedia: $e');
//       rethrow;
//     }
//   }

//   Future<void> _createPeerConnection() async {
//     _peerConnection = await createPeerConnection(_iceServers);
//     _registerPeerConnectionListeners();
//   }

//   void _registerPeerConnectionListeners() {
//     _peerConnection?.onConnectionState = (state) {
//       log('PeerConnection state: $state');
//     };

//     _peerConnection?.onIceConnectionState = (state) {
//       log('ICE connection state: $state');
//     };

//     _peerConnection?.onAddStream = (stream) {
//       log('onAddStream remote');
//       onAddRemoteStream?.call(stream);
//     };
//   }

//   /// Caller creates a room and writes offer to /rooms/{roomId}
//   Future<String> createRoom(String callerId, String receiverId,
//       {Duration unansweredTimeout = const Duration(seconds: 45)}) async {
//     if (_localStream == null) throw Exception('Local stream not opened');

//     await _createPeerConnection();

//     // Add tracks (modern approach)
//     for (var track in _localStream!.getTracks()) {
//       _peerConnection?.addTrack(track, _localStream!);
//     }

//     final roomRef = _firestore.collection('rooms').doc();
//     final callerCandidatesRef = roomRef.collection('callerCandidates');

//     // ICE candidate from local -> store in callerCandidates
//     _peerConnection?.onIceCandidate = (RTCIceCandidate? candidate) async {
//       if (candidate == null) return;
//       try {
//         await callerCandidatesRef.add(candidate.toMap());
//       } catch (e) {
//         log('Failed to add caller candidate: $e');
//       }
//     };

//     // Create offer
//     final offer = await _peerConnection!.createOffer();
//     await _peerConnection!.setLocalDescription(offer);

//     // Persist room
//     await roomRef.set({
//       'offer': offer.toMap(),
//       'callerId': callerId,
//       'receiverId': receiverId,
//       'status': 'ringing',
//       'createdAt': FieldValue.serverTimestamp(),
//     });

//     // Notify receiver by creating incoming_call doc in receiver user node
//     await _firestore
//         .collection('users')
//         .doc(receiverId)
//         .collection('incoming_call')
//         .doc('active')
//         .set({
//       'roomId': roomRef.id,
//       'callerId': callerId,
//       'isVideo': true,
//       'createdAt': FieldValue.serverTimestamp(),
//     });

//     // Listen for answer
//     roomRef.snapshots().listen((snapshot) async {
//       final data = snapshot.data();
//       if (data == null) return;

//       // If callee answered
//       if (data['answer'] != null) {
//         try {
//           final answer = data['answer'];
//           final remoteDesc =
//               RTCSessionDescription(answer['sdp'], answer['type']);

//           final currentRemote = await _peerConnection?.getRemoteDescription();
//           if (currentRemote == null) {
//             await _peerConnection?.setRemoteDescription(remoteDesc);
//             log('Remote description set (caller)');
//           }
//         } catch (e) {
//           log('Failed setting remote description (caller): $e');
//         }
//       }

//       // If status changed to ended/rejected -> cleanup
//       if (data['status'] == 'ended' || data['status'] == 'rejected') {
//         // Caller should handle UI close externally; signaling just cleans up
//         await _cleanupRoom(roomRef.id);
//       }
//     });

//     // Listen for callee ICE candidates
//     roomRef.collection('calleeCandidates').snapshots().listen((snap) {
//       for (var change in snap.docChanges) {
//         if (change.type == DocumentChangeType.added) {
//           final d = change.doc.data()!;
//           try {
//             _peerConnection?.addCandidate(RTCIceCandidate(
//                 d['candidate'], d['sdpMid'], d['sdpMLineIndex']));
//             log('Added callee ICE candidate');
//           } catch (e) {
//             log('Failed to add callee ICE candidate: $e');
//           }
//         }
//       }
//     });

//     // Start unanswered timeout watcher (if still ringing after timeout -> end call)
//     Timer(unansweredTimeout, () async {
//       final roomSnap = await roomRef.get();
//       if (!roomSnap.exists) return;
//       final st = roomSnap.data()?['status'];
//       if (st == 'ringing') {
//         // mark ended and cleanup
//         await roomRef.update({'status': 'ended'});
//         await _firestore
//             .collection('users')
//             .doc(receiverId)
//             .collection('incoming_call')
//             .doc('active')
//             .delete()
//             .catchError((_) {});
//         await _cleanupRoom(roomRef.id);
//         log('Call timed out (no answer)');
//       }
//     });

//     return roomRef.id;
//   }

//   /// Callee joins an existing room
//   Future<void> joinRoom(String roomId, {String? receiverUserId}) async {
//     final roomRef = _firestore.collection('rooms').doc(roomId);
//     final snapshot = await roomRef.get();
//     if (!snapshot.exists) throw Exception('Room not found');

//     final data = snapshot.data()!;

//     // Create peer connection
//     await _createPeerConnection();

//     // Add local tracks
//     if (_localStream != null) {
//       for (var track in _localStream!.getTracks()) {
//         _peerConnection?.addTrack(track, _localStream!);
//       }
//     }

//     // Add candidate writer for calleeCandidates
//     final calleeCandidatesRef = roomRef.collection('calleeCandidates');
//     _peerConnection?.onIceCandidate = (RTCIceCandidate? candidate) async {
//       if (candidate == null) return;
//       try {
//         await calleeCandidatesRef.add(candidate.toMap());
//       } catch (e) {
//         log('Failed to add callee candidate: $e');
//       }
//     };

//     // Handle incoming remote tracks
//     _peerConnection?.onAddStream = (stream) {
//       onAddRemoteStream?.call(stream);
//     };

//     // Set remote offer
//     final offer = data['offer'];
//     await _peerConnection!.setRemoteDescription(
//         RTCSessionDescription(offer['sdp'], offer['type']));

//     // Create answer
//     final answer = await _peerConnection!.createAnswer();
//     await _peerConnection!.setLocalDescription(answer);

//     // Save answer & mark accepted
//     await roomRef.update({'answer': answer.toMap(), 'status': 'accepted'});

//     // Optional: remove incoming_call doc (callee handled)
//     if (receiverUserId != null) {
//       try {
//         await _firestore
//             .collection('users')
//             .doc(receiverUserId)
//             .collection('incoming_call')
//             .doc('active')
//             .delete();
//       } catch (e) {
//         log('Failed deleting incoming_call doc: $e');
//       }
//     }

//     // Listen for caller ICE candidates
//     roomRef.collection('callerCandidates').snapshots().listen((snap) {
//       for (var change in snap.docChanges) {
//         if (change.type == DocumentChangeType.added) {
//           final d = change.doc.data()!;
//           try {
//             _peerConnection?.addCandidate(RTCIceCandidate(
//                 d['candidate'], d['sdpMid'], d['sdpMLineIndex']));
//             log('Added caller ICE candidate');
//           } catch (e) {
//             log('Failed to add caller ICE candidate: $e');
//           }
//         }
//       }
//     });
//   }

//   /// Hang up and cleanup: local + remote cleanup
//   Future<void> hangUp(String? roomId, {String? receiverId}) async {
//     // stop local tracks
//     try {
//       await _localStream?.dispose();
//     } catch (e) {
//       log('Error disposing local stream: $e');
//     }

//     try {
//       await _peerConnection?.close();
//     } catch (e) {
//       log('Error closing peer connection: $e');
//     }

//     // delete incoming_call doc for receiver
//     if (receiverId != null) {
//       await _firestore
//           .collection('users')
//           .doc(receiverId)
//           .collection('incoming_call')
//           .doc('active')
//           .delete()
//           .catchError((_) {});
//     }

//     // Delete room and candidate subcollections if roomId provided
//     if (roomId != null) {
//       await _cleanupRoom(roomId);
//     }

//     _peerConnection = null;
//     _localStream = null;
//   }

//   Future<void> _cleanupRoom(String roomId) async {
//     final roomRef = _firestore.collection('rooms').doc(roomId);

//     // delete candidates subcollections
//     try {
//       final callerCol = roomRef.collection('callerCandidates');
//       final calleeCol = roomRef.collection('calleeCandidates');

//       final callerSnap = await callerCol.get();
//       for (var doc in callerSnap.docs) {
//         await doc.reference.delete();
//       }

//       final calleeSnap = await calleeCol.get();
//       for (var doc in calleeSnap.docs) {
//         await doc.reference.delete();
//       }

//       await roomRef.delete();
//     } catch (e) {
//       log('Failed cleanup room $roomId: $e');
//     }
//   }
// }

// // ---------------- UI: WebRTCCallScreen ----------------

// class WebRTCCallScreen extends StatefulWidget {
//   final String currentUserName;
//   final String receiverName;
//   final String currentUserId;
//   final String receiverId;
//   final String callType;
//   final bool isCaller;
//   final String? roomId;

//   const WebRTCCallScreen({
//     super.key,
//     required this.callType,
//     required this.receiverName,
//     required this.currentUserName,
//     required this.currentUserId,
//     required this.receiverId,
//     required this.isCaller,
//     this.roomId,
//   });

//   @override
//   State<WebRTCCallScreen> createState() => _WebRTCCallScreenState();
// }

// class _WebRTCCallScreenState extends State<WebRTCCallScreen> {
//   final Signaling signaling = Signaling();
//   final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
//   final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

//   String? _roomId;
//   bool _isEnding = false;
//   bool _isMicMuted = false;
//   bool _isVideoMuted = false;

//   StreamSubscription? _incomingCallSub;

//   MediaStream get localStream => _localRenderer.srcObject!;

//   @override
//   void initState() {
//     super.initState();
//     _initRenderers();
//     _startCallFlow();
//   }

//   Future<void> _initRenderers() async {
//     await _localRenderer.initialize();
//     await _remoteRenderer.initialize();
//   }

//   Future<void> _startCallFlow() async {
//     signaling.onAddRemoteStream = (stream) {
//       setState(() => _remoteRenderer.srcObject = stream);
//     };

//     try {
//       await signaling.openUserMedia(_localRenderer);

//       if (widget.isCaller) {
//         _roomId =
//             await signaling.createRoom(widget.currentUserId, widget.receiverId);

//         _incomingCallSub = FirebaseFirestore.instance
//             .collection('users')
//             .doc(widget.receiverId)
//             .collection('incoming_call')
//             .doc('active')
//             .snapshots()
//             .listen((snap) async {
//           if (!snap.exists) return;
//           final data = snap.data();
//           if (data == null) return;

//           if (data['status'] == 'rejected') {
//             await _endCallCleanup();
//             if (mounted) Navigator.pop(context);
//             ScaffoldMessenger.of(context)
//                 .showSnackBar(const SnackBar(content: Text('Call Rejected')));
//           }
//         });
//       } else {
//         if (widget.roomId == null)
//           throw Exception('roomId is required for callee');
//         _roomId = widget.roomId;
//         await signaling.joinRoom(widget.roomId!,
//             receiverUserId: widget.currentUserId);
//       }
//     } catch (e) {
//       log('Call start failed: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text('Call failed: $e')));
//         Navigator.pop(context);
//       }
//     }
//   }

//   Future<void> _endCallCleanup() async {
//     if (_isEnding) return;
//     _isEnding = true;

//     try {
//       await signaling.hangUp(_roomId, receiverId: widget.receiverId);
//     } catch (e) {
//       log('Error in hangUp: $e');
//     }

//     await _disposeRenderersSafely();
//   }

//   Future<void> _disposeRenderersSafely() async {
//     try {
//       _localRenderer.srcObject = null;
//       _remoteRenderer.srcObject = null;
//       await Future.delayed(const Duration(milliseconds: 120));
//       if (_localRenderer.textureId != null) await _localRenderer.dispose();
//       if (_remoteRenderer.textureId != null) await _remoteRenderer.dispose();
//     } catch (e) {
//       log('Renderer dispose error: $e');
//     }
//   }

//   void _hangUp() async {
//     await _endCallCleanup();
//     if (mounted) Navigator.pop(context);
//   }

//   void _toggleMic() {
//     setState(() => _isMicMuted = !_isMicMuted);
//     localStream.getAudioTracks().first.enabled = !_isMicMuted;
//   }

//   void _toggleVideo() {
//     setState(() => _isVideoMuted = !_isVideoMuted);
//     localStream.getVideoTracks().first.enabled = !_isVideoMuted;
//   }

//   void _switchCamera() {
//     final track = localStream.getVideoTracks().first;
//     Helper.switchCamera(track);
//   }

//   @override
//   void dispose() {
//     _incomingCallSub?.cancel();
//     _endCallCleanup();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: RTCVideoView(
//               _remoteRenderer,
//               objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
//             ),
//           ),
//           Positioned(
//             right: 16,
//             top: 40,
//             child: SizedBox(
//               width: 120,
//               height: 160,
//               child: RTCVideoView(
//                 _localRenderer,
//                 mirror: true,
//                 objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
//               ),
//             ),
//           ),

//           // ✅ Bottom Control Bar
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 20),
//               color: Colors.black.withOpacity(0.3),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   // Mic
//                   CircleAvatar(
//                     radius: 28,
//                     backgroundColor: _isMicMuted ? Colors.red : Colors.white,
//                     child: IconButton(
//                       icon: Icon(
//                         _isMicMuted ? Icons.mic_off : Icons.mic,
//                         color: _isMicMuted ? Colors.white : Colors.black,
//                         size: 28,
//                       ),
//                       onPressed: _toggleMic,
//                     ),
//                   ),
//                   // Video
//                   CircleAvatar(
//                     radius: 28,
//                     backgroundColor: _isVideoMuted ? Colors.red : Colors.white,
//                     child: IconButton(
//                       icon: Icon(
//                         _isVideoMuted ? Icons.videocam_off : Icons.videocam,
//                         color: _isVideoMuted ? Colors.white : Colors.black,
//                         size: 28,
//                       ),
//                       onPressed: _toggleVideo,
//                     ),
//                   ),
//                   // Switch Camera
//                   CircleAvatar(
//                     radius: 28,
//                     backgroundColor: Colors.white,
//                     child: IconButton(
//                       icon: const Icon(Icons.cameraswitch,
//                           size: 28, color: Colors.black),
//                       onPressed: _switchCamera,
//                     ),
//                   ),
//                   // End Call
//                   CircleAvatar(
//                     radius: 32,
//                     backgroundColor: Colors.red,
//                     child: IconButton(
//                       icon: const Icon(Icons.call_end,
//                           size: 30, color: Colors.white),
//                       onPressed: _hangUp,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// // ---------------- UI: IncomingCallScreen ----------------
// class IncomingCallScreen extends StatelessWidget {
//   final String currentUserId;
//   final String currentUserName;
//   final String callerId;
//   final String callerName;
//   final String roomId;

//   const IncomingCallScreen({
//     super.key,
//     required this.currentUserId,
//     required this.currentUserName,
//     required this.callerId,
//     required this.callerName,
//     required this.roomId,
//   });

//   Future<void> _acceptCall(BuildContext context) async {
//     final userCallDoc = FirebaseFirestore.instance
//         .collection('users')
//         .doc(currentUserId)
//         .collection('incoming_call')
//         .doc('active');

//     await userCallDoc.update({'status': 'accepted'}).catchError((_) {});

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (_) => WebRTCCallScreen(
//           callType: "video",
//           currentUserId: currentUserId,
//           currentUserName: currentUserName,
//           receiverId: callerId,
//           receiverName: callerName,
//           isCaller: false,
//           roomId: roomId,
//         ),
//       ),
//     );
//   }

//   Future<void> _rejectCall(BuildContext context) async {
//     final userCallDoc = FirebaseFirestore.instance
//         .collection('users')
//         .doc(currentUserId)
//         .collection('incoming_call')
//         .doc('active');

//     await userCallDoc.update({'status': 'rejected'}).catchError((_) {});
//     await userCallDoc.delete().catchError((_) {});

//     await FirebaseFirestore.instance
//         .collection('rooms')
//         .doc(roomId)
//         .update({'status': 'rejected'})
//         .catchError((_) {});

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

//             Text(
//               '$callerName is calling…',
//               style: const TextStyle(color: Colors.white, fontSize: 22),
//             ),

//             const SizedBox(height: 40),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 FloatingActionButton(
//                   heroTag: 'webrtc_call_reject',
//                   backgroundColor: Colors.red,
//                   onPressed: () => _rejectCall(context),
//                   child: const Icon(Icons.call_end),
//                 ),
//                 FloatingActionButton(
//                   heroTag: 'webrtc_call_accept',
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








// // ---------------- End of file ----------------
// import 'dart:async';
// import 'dart:developer';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';

// typedef StreamCallback = void Function(MediaStream stream);

// class Signaling {
//   RTCPeerConnection? _peerConnection;
//   MediaStream? _localStream;
//   StreamCallback? onAddRemoteStream;

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   final Map<String, dynamic> _iceServers = {
//     'iceServers': [
//       {'urls': 'stun:stun1.l.google.com:19302'},
//     ]
//   };

//   Future<void> openUserMedia(RTCVideoRenderer localRenderer) async {
//     final stream = await navigator.mediaDevices.getUserMedia({
//       'audio': true,
//       'video': {'facingMode': 'user'},
//     });
//     _localStream = stream;
//     localRenderer.srcObject = stream;
//   }

//   Future<void> _createPeerConnection() async {
//     _peerConnection = await createPeerConnection(_iceServers);
//     _peerConnection?.onAddStream = (stream) {
//       onAddRemoteStream?.call(stream);
//     };
//     _peerConnection?.onConnectionState = (state) => log('Connection state: $state');
//     _peerConnection?.onIceConnectionState = (state) => log('ICE state: $state');
//   }

//   Future<String> createRoom(String callerId, String receiverId,
//       {Duration unansweredTimeout = const Duration(seconds: 45)}) async {
//     if (_localStream == null) throw Exception('Local stream not opened');

//     await _createPeerConnection();
//     for (var track in _localStream!.getTracks()) {
//       _peerConnection?.addTrack(track, _localStream!);
//     }

//     final roomRef = _firestore.collection('rooms').doc();
//     final callerCandidates = roomRef.collection('callerCandidates');

//     _peerConnection?.onIceCandidate = (RTCIceCandidate? candidate) async {
//       if (candidate != null) await callerCandidates.add(candidate.toMap());
//     };

//     final offer = await _peerConnection!.createOffer();
//     await _peerConnection!.setLocalDescription(offer);

//     await roomRef.set({
//       'offer': offer.toMap(),
//       'callerId': callerId,
//       'receiverId': receiverId,
//       'status': 'ringing',
//       'createdAt': FieldValue.serverTimestamp(),
//     });

//     await _firestore
//         .collection('users')
//         .doc(receiverId)
//         .collection('incoming_call')
//         .doc('active')
//         .set({
//       'roomId': roomRef.id,
//       'callerId': callerId,
//       'isVideo': true,
//       'createdAt': FieldValue.serverTimestamp(),
//     });

//     // Listen for answer & status change
//     roomRef.snapshots().listen((snap) async {
//       final data = snap.data();
//       if (data == null) return;

//       if (data['answer'] != null) {
//         final remoteDesc = RTCSessionDescription(data['answer']['sdp'], data['answer']['type']);
//         if ((await _peerConnection?.getRemoteDescription()) == null) {
//           await _peerConnection?.setRemoteDescription(remoteDesc);
//         }
//       }

//       if (data['status'] == 'ended' || data['status'] == 'rejected') {
//         await hangUp(roomRef.id, receiverId: receiverId);
//       }
//     });

//     // Listen for callee ICE
//     roomRef.collection('calleeCandidates').snapshots().listen((snap) {
//       for (var change in snap.docChanges) {
//         if (change.type == DocumentChangeType.added) {
//           final d = change.doc.data()!;
//           _peerConnection?.addCandidate(RTCIceCandidate(d['candidate'], d['sdpMid'], d['sdpMLineIndex']));
//         }
//       }
//     });

//     // Timeout if unanswered
//     Timer(unansweredTimeout, () async {
//       final st = (await roomRef.get()).data()?['status'];
//       if (st == 'ringing') {
//         await roomRef.update({'status': 'ended'});
//         await _firestore
//             .collection('users')
//             .doc(receiverId)
//             .collection('incoming_call')
//             .doc('active')
//             .delete()
//             .catchError((_) {});
//         await _cleanupRoom(roomRef.id);
//       }
//     });

//     return roomRef.id;
//   }

//   Future<void> joinRoom(String roomId, {String? receiverUserId}) async {
//     final roomRef = _firestore.collection('rooms').doc(roomId);
//     final snapshot = await roomRef.get();
//     if (!snapshot.exists) throw Exception('Room not found');

//     await _createPeerConnection();

//     if (_localStream != null) {
//       for (var track in _localStream!.getTracks()) _peerConnection?.addTrack(track, _localStream!);
//     }

//     final calleeCandidates = roomRef.collection('calleeCandidates');
//     _peerConnection?.onIceCandidate = (RTCIceCandidate? c) async {
//       if (c != null) await calleeCandidates.add(c.toMap());
//     };

//     _peerConnection?.onAddStream = (stream) => onAddRemoteStream?.call(stream);

//     final offer = snapshot.data()!['offer'];
//     await _peerConnection!.setRemoteDescription(RTCSessionDescription(offer['sdp'], offer['type']));

//     final answer = await _peerConnection!.createAnswer();
//     await _peerConnection!.setLocalDescription(answer);

//     await roomRef.update({'answer': answer.toMap(), 'status': 'accepted'});

//     if (receiverUserId != null) {
//       await _firestore
//           .collection('users')
//           .doc(receiverUserId)
//           .collection('incoming_call')
//           .doc('active')
//           .delete()
//           .catchError((_) {});
//     }

//     // Listen for caller ICE
//     roomRef.collection('callerCandidates').snapshots().listen((snap) {
//       for (var change in snap.docChanges) {
//         if (change.type == DocumentChangeType.added) {
//           final d = change.doc.data()!;
//           _peerConnection?.addCandidate(RTCIceCandidate(d['candidate'], d['sdpMid'], d['sdpMLineIndex']));
//         }
//       }
//     });
//   }

//   Future<void> hangUp(String? roomId, {String? receiverId}) async {
//     try {
//       _localStream?.getTracks().forEach((t) => t.stop());
//       _peerConnection?.close();
//     } catch (e) {
//       log('Hangup error: $e');
//     }

//     if (receiverId != null) {
//       FirebaseFirestore.instance
//           .collection('users')
//           .doc(receiverId)
//           .collection('incoming_call')
//           .doc('active')
//           .delete()
//           .catchError((_) {});
//     }

//     if (roomId != null) _cleanupRoom(roomId);

//     _peerConnection = null;
//     _localStream = null;
//   }

//   Future<void> _cleanupRoom(String roomId) async {
//     final roomRef = _firestore.collection('rooms').doc(roomId);
//     try {
//       final callerCol = roomRef.collection('callerCandidates');
//       final calleeCol = roomRef.collection('calleeCandidates');

//       final callerSnap = await callerCol.get();
//       for (var doc in callerSnap.docs) await doc.reference.delete();

//       final calleeSnap = await calleeCol.get();
//       for (var doc in calleeSnap.docs) await doc.reference.delete();

//       await roomRef.delete();
//     } catch (e) {
//       log('Failed cleanup room $roomId: $e');
//     }
//   }
// }

// // -------------------- WebRTCCallScreen --------------------
// class WebRTCCallScreen extends StatefulWidget {
//   final String currentUserName;
//   final String receiverName;
//   final String currentUserId;
//   final String receiverId;
//   final String callType;
//   final bool isCaller;
//   final String? roomId;

//   const WebRTCCallScreen({
//     super.key,
//     required this.callType,
//     required this.receiverName,
//     required this.currentUserName,
//     required this.currentUserId,
//     required this.receiverId,
//     required this.isCaller,
//     this.roomId,
//   });

//   @override
//   State<WebRTCCallScreen> createState() => _WebRTCCallScreenState();
// }

// class _WebRTCCallScreenState extends State<WebRTCCallScreen> {
//   final Signaling signaling = Signaling();
//   final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
//   final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

//   String? _roomId;
//   bool _isEnding = false;
//   bool _isMicMuted = false;
//   bool _isVideoMuted = false;

//   StreamSubscription? _incomingCallSub;

//   MediaStream get localStream => _localRenderer.srcObject!;

//   @override
//   void initState() {
//     super.initState();
//     _initRenderers();
//     _startCallFlow();
//   }

//   Future<void> _initRenderers() async {
//     await _localRenderer.initialize();
//     await _remoteRenderer.initialize();
//   }

//   Future<void> _startCallFlow() async {
//     signaling.onAddRemoteStream = (stream) {
//       setState(() => _remoteRenderer.srcObject = stream);
//     };

//     try {
//       await signaling.openUserMedia(_localRenderer);

//       if (widget.isCaller) {
//         _roomId = await signaling.createRoom(widget.currentUserId, widget.receiverId);

//         _incomingCallSub = FirebaseFirestore.instance
//             .collection('users')
//             .doc(widget.receiverId)
//             .collection('incoming_call')
//             .doc('active')
//             .snapshots()
//             .listen((snap) async {
//           if (!snap.exists) return;
//           final data = snap.data();
//           if (data == null) return;

//           if (data['status'] == 'rejected') {
//             await _endCallCleanup();
//             if (mounted) Navigator.pop(context);
//           }
//         });
//       } else {
//         if (widget.roomId == null) throw Exception('roomId required for callee');
//         _roomId = widget.roomId;
//         await signaling.joinRoom(widget.roomId!, receiverUserId: widget.currentUserId);
//       }
//     } catch (e) {
//       log('Call start failed: $e');
//       if (mounted) Navigator.pop(context);
//     }
//   }

//   Future<void> _endCallCleanup() async {
//     if (_isEnding) return;
//     _isEnding = true;
//     await signaling.hangUp(_roomId, receiverId: widget.receiverId);
//     _localRenderer.srcObject = null;
//     _remoteRenderer.srcObject = null;
//   }

//   void _hangUp() async {
//     await _endCallCleanup();
//     if (mounted) Navigator.pop(context);
//   }

//   void _toggleMic() {
//     setState(() => _isMicMuted = !_isMicMuted);
//     localStream.getAudioTracks().first.enabled = !_isMicMuted;
//   }

//   void _toggleVideo() {
//     setState(() => _isVideoMuted = !_isVideoMuted);
//     localStream.getVideoTracks().first.enabled = !_isVideoMuted;
//   }

//   void _switchCamera() {
//     final track = localStream.getVideoTracks().first;
//     Helper.switchCamera(track);
//   }

//   @override
//   void dispose() {
//     _incomingCallSub?.cancel();
//     _endCallCleanup();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: RTCVideoView(_remoteRenderer, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
//           ),
//           Positioned(
//             right: 16,
//             top: 40,
//             child: SizedBox(
//               width: 120,
//               height: 160,
//               child: RTCVideoView(_localRenderer, mirror: true, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
//             ),
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 20),
//               color: Colors.black.withOpacity(0.3),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   CircleAvatar(
//                     radius: 28,
//                     backgroundColor: _isMicMuted ? Colors.red : Colors.white,
//                     child: IconButton(
//                       icon: Icon(_isMicMuted ? Icons.mic_off : Icons.mic,
//                           color: _isMicMuted ? Colors.white : Colors.black, size: 28),
//                       onPressed: _toggleMic,
//                     ),
//                   ),
//                   CircleAvatar(
//                     radius: 28,
//                     backgroundColor: _isVideoMuted ? Colors.red : Colors.white,
//                     child: IconButton(
//                       icon: Icon(_isVideoMuted ? Icons.videocam_off : Icons.videocam,
//                           color: _isVideoMuted ? Colors.white : Colors.black, size: 28),
//                       onPressed: _toggleVideo,
//                     ),
//                   ),
//                   CircleAvatar(
//                     radius: 28,
//                     backgroundColor: Colors.white,
//                     child: IconButton(
//                       icon: const Icon(Icons.cameraswitch, size: 28, color: Colors.black),
//                       onPressed: _switchCamera,
//                     ),
//                   ),
//                   CircleAvatar(
//                     radius: 32,
//                     backgroundColor: Colors.red,
//                     child: IconButton(
//                       icon: const Icon(Icons.call_end, size: 30, color: Colors.white),
//                       onPressed: _hangUp,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // -------------------- IncomingCallScreen --------------------
// class IncomingCallScreen extends StatelessWidget {
//   final String currentUserId;
//   final String currentUserName;
//   final String callerId;
//   final String callerName;
//   final String roomId;

//   const IncomingCallScreen({
//     super.key,
//     required this.currentUserId,
//     required this.currentUserName,
//     required this.callerId,
//     required this.callerName,
//     required this.roomId,
//   });

//   Future<void> _acceptCall(BuildContext context) async {
//     final userCallDoc = FirebaseFirestore.instance
//         .collection('users')
//         .doc(currentUserId)
//         .collection('incoming_call')
//         .doc('active');

//     await userCallDoc.update({'status': 'accepted'}).catchError((_) {});

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (_) => WebRTCCallScreen(
//           callType: "video",
//           currentUserId: currentUserId,
//           currentUserName: currentUserName,
//           receiverId: callerId,
//           receiverName: callerName,
//           isCaller: false,
//           roomId: roomId,
//         ),
//       ),
//     );
//   }

//   Future<void> _rejectCall(BuildContext context) async {
//     final userCallDoc = FirebaseFirestore.instance
//         .collection('users')
//         .doc(currentUserId)
//         .collection('incoming_call')
//         .doc('active');

//     await userCallDoc.update({'status': 'rejected'}).catchError((_) {});
//     await userCallDoc.delete().catchError((_) {});

//     await FirebaseFirestore.instance.collection('rooms').doc(roomId).update({'status': 'rejected'}).catchError((_) {});
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
//             Text('$callerName is calling…', style: const TextStyle(color: Colors.white, fontSize: 22)),
//             const SizedBox(height: 40),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 FloatingActionButton(
//                   heroTag: 'webrtc_call_reject',
//                   backgroundColor: Colors.red,
//                   onPressed: () => _rejectCall(context),
//                   child: const Icon(Icons.call_end),
//                 ),
//                 FloatingActionButton(
//                   heroTag: 'webrtc_call_accept',
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



import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

typedef StreamCallback = void Function(MediaStream stream);

class Signaling {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  StreamCallback? onAddRemoteStream;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun1.l.google.com:19302'},
    ]
  };

  Future<void> openUserMedia(RTCVideoRenderer localRenderer) async {
    final stream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {'facingMode': 'user'}
    });
    localRenderer.srcObject = stream;
    _localStream = stream;
  }

  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection(_iceServers);
    _peerConnection?.onConnectionState = (state) => log('Connection: $state');
    _peerConnection?.onIceConnectionState = (state) => log('ICE: $state');
    _peerConnection?.onAddStream = (stream) => onAddRemoteStream?.call(stream);
  }

  Future<String> createRoom(String callerId, String receiverId) async {
    if (_localStream == null) throw Exception('Local stream not opened');
    await _createPeerConnection();
    _localStream!.getTracks().forEach((track) => _peerConnection?.addTrack(track, _localStream!));

    final roomRef = _firestore.collection('rooms').doc();
    final callerCandidatesRef = roomRef.collection('callerCandidates');

    _peerConnection?.onIceCandidate = (candidate) {
      if (candidate != null) callerCandidatesRef.add(candidate.toMap());
    };

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    await roomRef.set({
      'offer': offer.toMap(),
      'callerId': callerId,
      'receiverId': receiverId,
      'status': 'ringing',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore
        .collection('users')
        .doc(receiverId)
        .collection('incoming_call')
        .doc('active')
        .set({'roomId': roomRef.id, 'callerId': callerId, 'createdAt': FieldValue.serverTimestamp()});

    // Listen for callee answer and ICE
    roomRef.snapshots().listen((snap) async {
      final data = snap.data();
      if (data == null) return;

      if (data['answer'] != null) {
        final answer = data['answer'];
        final remoteDesc = RTCSessionDescription(answer['sdp'], answer['type']);
        if ((await _peerConnection?.getRemoteDescription()) == null) {
          await _peerConnection?.setRemoteDescription(remoteDesc);
        }
      }
    });

    roomRef.collection('calleeCandidates').snapshots().listen((snap) {
      for (var change in snap.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final d = change.doc.data()!;
          _peerConnection?.addCandidate(RTCIceCandidate(d['candidate'], d['sdpMid'], d['sdpMLineIndex']));
        }
      }
    });

    return roomRef.id;
  }

  Future<void> joinRoom(String roomId, {String? receiverUserId}) async {
    final roomRef = _firestore.collection('rooms').doc(roomId);
    final snapshot = await roomRef.get();
    if (!snapshot.exists) throw Exception('Room not found');

    await _createPeerConnection();
    _localStream?.getTracks().forEach((track) => _peerConnection?.addTrack(track, _localStream!));

    final calleeCandidatesRef = roomRef.collection('calleeCandidates');
    _peerConnection?.onIceCandidate = (candidate) {
      if (candidate != null) calleeCandidatesRef.add(candidate.toMap());
    };

    final offer = snapshot.data()!['offer'];
    await _peerConnection!.setRemoteDescription(RTCSessionDescription(offer['sdp'], offer['type']));

    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    await roomRef.update({'answer': answer.toMap(), 'status': 'accepted'});

    if (receiverUserId != null) {
      await _firestore.collection('users').doc(receiverUserId).collection('incoming_call').doc('active').delete();
    }

    roomRef.collection('callerCandidates').snapshots().listen((snap) {
      for (var change in snap.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final d = change.doc.data()!;
          _peerConnection?.addCandidate(RTCIceCandidate(d['candidate'], d['sdpMid'], d['sdpMLineIndex']));
        }
      }
    });
  }

  Future<void> hangUp(String? roomId, {String? receiverId}) async {
    await _localStream?.dispose();
    await _peerConnection?.close();

    if (receiverId != null) {
      await _firestore.collection('users').doc(receiverId).collection('incoming_call').doc('active').delete().catchError((_) {});
    }

    if (roomId != null) {
      await _cleanupRoom(roomId);
    }

    _localStream = null;
    _peerConnection = null;
  }

  Future<void> _cleanupRoom(String roomId) async {
    final roomRef = _firestore.collection('rooms').doc(roomId);
    try {
      final callerCol = roomRef.collection('callerCandidates');
      final calleeCol = roomRef.collection('calleeCandidates');
      for (var doc in (await callerCol.get()).docs) await doc.reference.delete();
      for (var doc in (await calleeCol.get()).docs) await doc.reference.delete();
      await roomRef.delete();
    } catch (e) {
      log('Cleanup error: $e');
    }
  }
}

// ------------------ WebRTCCallScreen ------------------
class WebRTCCallScreen extends StatefulWidget {
  final String currentUserName, receiverName, currentUserId, receiverId, callType;
  final bool isCaller;
  final String? roomId;

  const WebRTCCallScreen({
    super.key,
    required this.currentUserName,
    required this.receiverName,
    required this.currentUserId,
    required this.receiverId,
    required this.callType,
    required this.isCaller,
    this.roomId,
  });

  @override
  State<WebRTCCallScreen> createState() => _WebRTCCallScreenState();
}

class _WebRTCCallScreenState extends State<WebRTCCallScreen> {
  final Signaling signaling = Signaling();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  StreamSubscription? _roomSub;

  String? _roomId;
  bool _isEnding = false, _isMicMuted = false, _isVideoMuted = false;

  MediaStream get localStream => _localRenderer.srcObject!;

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _startCallFlow();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> _startCallFlow() async {
    signaling.onAddRemoteStream = (stream) => setState(() => _remoteRenderer.srcObject = stream);
    await signaling.openUserMedia(_localRenderer);

    if (widget.isCaller) {
      _roomId = await signaling.createRoom(widget.currentUserId, widget.receiverId);
    } else {
      if (widget.roomId == null) throw Exception('roomId required');
      _roomId = widget.roomId;
      await signaling.joinRoom(widget.roomId!, receiverUserId: widget.currentUserId);
    }

    _listenRoomStatus();
  }

  void _listenRoomStatus() {
    if (_roomId == null) return;
    final roomRef = FirebaseFirestore.instance.collection('rooms').doc(_roomId);

    _roomSub = roomRef.snapshots().listen((snap) async {
      final data = snap.data();
      if (data == null) return;

      final status = data['status'];
      if (status == 'ended' || status == 'rejected') {
        await _endCallCleanup();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Call ${status == 'ended' ? 'ended' : 'rejected'}')));
          Navigator.pop(context);
        }
      }
    });
  }

  Future<void> _endCallCleanup() async {
    if (_isEnding) return;
    _isEnding = true;
    await signaling.hangUp(_roomId, receiverId: widget.receiverId);
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;
    await _localRenderer.dispose();
    await _remoteRenderer.dispose();
  }

  void _hangUp() async {
    final roomRef = FirebaseFirestore.instance.collection('rooms').doc(_roomId);
    await roomRef.update({'status': 'ended'});
    await _endCallCleanup();
    if (mounted) Navigator.pop(context);
  }

  void _toggleMic() {
    setState(() => _isMicMuted = !_isMicMuted);
    localStream.getAudioTracks().first.enabled = !_isMicMuted;
  }

  void _toggleVideo() {
    setState(() => _isVideoMuted = !_isVideoMuted);
    localStream.getVideoTracks().first.enabled = !_isVideoMuted;
  }

  void _switchCamera() => Helper.switchCamera(localStream.getVideoTracks().first);

  @override
  void dispose() {
    _roomSub?.cancel();
    _endCallCleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: RTCVideoView(_remoteRenderer, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)),
          Positioned(
            top: 40,
            right: 16,
            child: SizedBox(
              width: 120,
              height: 160,
              child: RTCVideoView(_localRenderer, mirror: true, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: Colors.black.withOpacity(0.3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: _isMicMuted ? Colors.red : Colors.white,
                    child: IconButton(
                      icon: Icon(_isMicMuted ? Icons.mic_off : Icons.mic, color: _isMicMuted ? Colors.white : Colors.black, size: 28),
                      onPressed: _toggleMic,
                    ),
                  ),
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: _isVideoMuted ? Colors.red : Colors.white,
                    child: IconButton(
                      icon: Icon(_isVideoMuted ? Icons.videocam_off : Icons.videocam, color: _isVideoMuted ? Colors.white : Colors.black, size: 28),
                      onPressed: _toggleVideo,
                    ),
                  ),
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: IconButton(icon: const Icon(Icons.cameraswitch, color: Colors.black, size: 28), onPressed: _switchCamera),
                  ),
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.red,
                    child: IconButton(icon: const Icon(Icons.call_end, color: Colors.white, size: 30), onPressed: _hangUp),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------ IncomingCallScreen ------------------
class IncomingCallScreen extends StatelessWidget {
  final String currentUserId, currentUserName, callerId, callerName, roomId;

  const IncomingCallScreen({
    super.key,
    required this.currentUserId,
    required this.currentUserName,
    required this.callerId,
    required this.callerName,
    required this.roomId,
  });

  Future<void> _acceptCall(BuildContext context) async {
    final userCallDoc = FirebaseFirestore.instance.collection('users').doc(currentUserId).collection('incoming_call').doc('active');
    await userCallDoc.update({'status': 'accepted'}).catchError((_) {});

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WebRTCCallScreen(
          callType: "video",
          currentUserId: currentUserId,
          currentUserName: currentUserName,
          receiverId: callerId,
          receiverName: callerName,
          isCaller: false,
          roomId: roomId,
        ),
      ),
    );
  }

  Future<void> _rejectCall(BuildContext context) async {
    final userCallDoc = FirebaseFirestore.instance.collection('users').doc(currentUserId).collection('incoming_call').doc('active');
    await userCallDoc.update({'status': 'rejected'}).catchError((_) {});
    await userCallDoc.delete().catchError((_) {});
    await FirebaseFirestore.instance.collection('rooms').doc(roomId).update({'status': 'rejected'}).catchError((_) {});
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam, size: 80, color: Colors.white),
            const SizedBox(height: 30),
            Text('$callerName is calling…', style: const TextStyle(color: Colors.white, fontSize: 22)),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(heroTag: 'reject', backgroundColor: Colors.red, onPressed: () => _rejectCall(context), child: const Icon(Icons.call_end)),
                FloatingActionButton(heroTag: 'accept', backgroundColor: Colors.green, onPressed: () => _acceptCall(context), child: const Icon(Icons.call)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
