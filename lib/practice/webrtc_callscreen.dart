// import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:real_time_chat_application/practice/webrtc_signalling.dart';

// class WebRTCCallScreen extends StatefulWidget {
//   final String currentUserId;
//   final String receiverId;
//   final bool isCaller;
//   final String? roomId;

//   const WebRTCCallScreen({
//     super.key,
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

//   @override
//   void initState() {
//     super.initState();
//     _initRenderers();
//     _startCall();
//   }

//   Future<void> _initRenderers() async {
//     await _localRenderer.initialize();
//     await _remoteRenderer.initialize();
//   }

//   Future<void> _startCall() async {
//     signaling.onAddRemoteStream = (stream) {
//       setState(() => _remoteRenderer.srcObject = stream);
//     };

//     await signaling.openUserMedia(_localRenderer);

//     if (widget.isCaller) {
//       _roomId =
//           await signaling.createRoom(widget.currentUserId, widget.receiverId);
//       _listenForReceiverResponse();
//     } else {
//       await signaling.joinRoom(widget.roomId!);
//     }
//   }

//   void _listenForReceiverResponse() {
//     FirebaseFirestore.instance
//         .collection('users')
//         .doc(widget.receiverId)
//         .collection('incoming_call')
//         .doc('active')
//         .snapshots()
//         .listen((snap) async {
//       if (!snap.exists) return;
//       final status = snap.data()?['status'];
//       if (status == 'rejected') {
//         await signaling.hangUp(_roomId ?? '', widget.receiverId);
//         if (mounted) Navigator.pop(context);
//         ScaffoldMessenger.of(context)
//             .showSnackBar(const SnackBar(content: Text("Call Rejected")));
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _localRenderer.dispose();
//     _remoteRenderer.dispose();
//     super.dispose();
//   }

//   void _hangUp() async {
//     await signaling.hangUp(_roomId ?? widget.roomId!, widget.receiverId);
//     if (mounted) Navigator.pop(context);
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
//           Positioned(
//             bottom: 40,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: FloatingActionButton(
//                  heroTag: 'webrtc_call_fab', // 👈 Add unique hero tag

//                 backgroundColor: Colors.red,
//                 onPressed: _hangUp,
//                 child: const Icon(Icons.call_end),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }




//Doosri baar


// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:uuid/uuid.dart';

// class WebRTCCallScreen extends StatefulWidget {
//   final String currentUserId;
//   final String receiverId;
//   final bool isCaller;
//   final String? roomId;

//   const WebRTCCallScreen({
//     super.key,
//     required this.currentUserId,
//     required this.receiverId,
//     required this.isCaller,
//     this.roomId,
//   });

//   @override
//   State<WebRTCCallScreen> createState() => _WebRTCCallScreenState();
// }

// class _WebRTCCallScreenState extends State<WebRTCCallScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
//   final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

//   RTCPeerConnection? _peerConnection;
//   MediaStream? _localStream;
//   late String _callId;
//   StreamSubscription? _callSub;
//   StreamSubscription? _candidatesSub;

//   @override
//   void initState() {
//     super.initState();
//     _initRenderers();

//     _callId = widget.roomId ?? const Uuid().v4();

//     if (widget.isCaller) {
//       _startCall();
//     } else {
//       _joinCall();
//     }

//     _listenForCallStatus();
//   }

//   Future<void> _initRenderers() async {
//     await _localRenderer.initialize();
//     await _remoteRenderer.initialize();
//   }

//   /// 🔹 Listen to Firestore updates for call status (ended / rejected)
//   Future<void> _listenForCallStatus() async {
//     _callSub = _firestore.collection('calls').doc(_callId).snapshots().listen((snapshot) async {
//       if (!snapshot.exists) return;
//       final data = snapshot.data()!;
//       final status = data['status'];

//       if (status == 'rejected' || status == 'ended') {
//         await _endCall(remoteEnded: true);
//       }

//       // For caller: once receiver answers, set remote description
//       if (widget.isCaller && data['answer'] != null) {
//         await _setRemoteDescription(data);
//       }
//     });
//   }

//   /// 🔹 Caller initiates the call
//   Future<void> _startCall() async {
//     _localStream = await navigator.mediaDevices.getUserMedia({
//       'audio': true,
//       'video': true,
//     });

//     _localRenderer.srcObject = _localStream;

//     _peerConnection = await createPeerConnection({
//       'iceServers': [
//         {'urls': 'stun:stun.l.google.com:19302'},
//       ],
//     });

//     _peerConnection?.addStream(_localStream!);

//     _peerConnection?.onAddStream = (stream) {
//       _remoteRenderer.srcObject = stream;
//     };

//     // 🔸 Listen for ICE candidates
//     _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
//       if (candidate.candidate != null) {
//         _firestore.collection('calls').doc(_callId).collection('candidates').add(candidate.toMap());
//       }
//     };

//     // 🔸 Create offer
//     final offer = await _peerConnection!.createOffer();
//     await _peerConnection!.setLocalDescription(offer);

//     // 🔸 Store call document
//     await _firestore.collection('calls').doc(_callId).set({
//       'callerId': widget.currentUserId,
//       'receiverId': widget.receiverId,
//       'status': 'ringing',
//       'offer': offer.sdp,
//     });

//     // 🔸 Listen for remote ICE candidates (added by receiver)
//     _candidatesSub = _firestore
//         .collection('calls')
//         .doc(_callId)
//         .collection('candidates')
//         .snapshots()
//         .listen((snapshot) {
//       for (var doc in snapshot.docChanges) {
//         if (doc.type == DocumentChangeType.added) {
//           final data = doc.doc.data()!;
//           if (data['candidate'] != null) {
//             _peerConnection!.addCandidate(
//               RTCIceCandidate(data['candidate'], data['sdpMid'], data['sdpMLineIndex']),
//             );
//           }
//         }
//       }
//     });
//   }

//   /// 🔹 Receiver joins and answers the call
//   Future<void> _joinCall() async {
//     _localStream = await navigator.mediaDevices.getUserMedia({
//       'audio': true,
//       'video': true,
//     });
//     _localRenderer.srcObject = _localStream;

//     _peerConnection = await createPeerConnection({
//       'iceServers': [
//         {'urls': 'stun:stun.l.google.com:19302'},
//       ],
//     });

//     _peerConnection?.addStream(_localStream!);

//     _peerConnection?.onAddStream = (stream) {
//       _remoteRenderer.srcObject = stream;
//     };

//     _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
//       if (candidate.candidate != null) {
//         _firestore.collection('calls').doc(_callId).collection('candidates').add(candidate.toMap());
//       }
//     };

//     // 🔸 Get caller's offer
//     final callDoc = await _firestore.collection('calls').doc(_callId).get();
//     if (!callDoc.exists) {
//       debugPrint("❌ Offer not found. Cannot join call.");
//       return;
//     }

//     final data = callDoc.data()!;
//     final offer = data['offer'];
//     await _peerConnection!.setRemoteDescription(RTCSessionDescription(offer, 'offer'));

//     // 🔸 Create and send answer
//     final answer = await _peerConnection!.createAnswer();
//     await _peerConnection!.setLocalDescription(answer);

//     await _firestore.collection('calls').doc(_callId).update({
//       'answer': answer.sdp,
//       'status': 'accepted',
//     });

//     // 🔸 Listen for ICE candidates from caller
//     _candidatesSub = _firestore
//         .collection('calls')
//         .doc(_callId)
//         .collection('candidates')
//         .snapshots()
//         .listen((snapshot) {
//       for (var doc in snapshot.docChanges) {
//         if (doc.type == DocumentChangeType.added) {
//           final data = doc.doc.data()!;
//           if (data['candidate'] != null) {
//             _peerConnection!.addCandidate(
//               RTCIceCandidate(data['candidate'], data['sdpMid'], data['sdpMLineIndex']),
//             );
//           }
//         }
//       }
//     });
//   }

//   /// 🔹 Safely set remote description (for caller when answer arrives)
//   Future<void> _setRemoteDescription(Map<String, dynamic> data) async {
//     if (_peerConnection == null) {
//       debugPrint("⚠️ PeerConnection is null, skipping setRemoteDescription");
//       return;
//     }

//     final answerSdp = data['answer'];
//     if (answerSdp == null || answerSdp.isEmpty) {
//       debugPrint("⚠️ No valid answer SDP found.");
//       return;
//     }

//     try {
//       final desc = RTCSessionDescription(answerSdp, 'answer');
//       await _peerConnection!.setRemoteDescription(desc);
//       debugPrint("✅ Remote description set successfully.");
//     } catch (e) {
//       debugPrint("❌ Failed to set remote description: $e");
//     }
//   }

//   /// 🔹 End or reject call
//   Future<void> _endCall({bool remoteEnded = false}) async {
//     if (!remoteEnded) {
//       await _firestore.collection('calls').doc(_callId).update({'status': 'ended'});
//     }

//     await _peerConnection?.close();
//     _localStream?.getTracks().forEach((track) => track.stop());

//     _localRenderer.srcObject = null;
//     _remoteRenderer.srcObject = null;

//     if (mounted) {
//       Navigator.pop(context);
//     }
//   }

//   Future<void> _rejectCall() async {
//     await _firestore.collection('calls').doc(_callId).update({'status': 'rejected'});
//     await _endCall();
//   }

//   @override
//   void dispose() {
//     _callSub?.cancel();
//     _candidatesSub?.cancel();
//     _localRenderer.dispose();
//     _remoteRenderer.dispose();
//     _peerConnection?.dispose();
//     _localStream?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             RTCVideoView(_remoteRenderer, mirror: true),
//             Align(
//               alignment: Alignment.topRight,
//               child: Container(
//                 width: 120,
//                 height: 160,
//                 margin: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   color: Colors.black54,
//                 ),
//                 child: RTCVideoView(_localRenderer, mirror: true),
//               ),
//             ),
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Padding(
//                 padding: const EdgeInsets.all(32.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     FloatingActionButton(
//                       heroTag: 'rejectBtn',
//                       backgroundColor: Colors.red,
//                       onPressed: _rejectCall,
//                       child: const Icon(Icons.call_end),
//                     ),
//                     FloatingActionButton(
//                       heroTag: 'endBtn',
//                       backgroundColor: Colors.grey,
//                       onPressed: _endCall,
//                       child: const Icon(Icons.cancel),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:real_time_chat_application/practice/webrtc_signalling.dart';

class WebRTCCallScreen extends StatefulWidget {
  final String currentUserId;
  final String receiverId;
  final bool isCaller;
  final String? roomId;

  const WebRTCCallScreen({
    super.key,
    required this.currentUserId,
    required this.receiverId,
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

  String? _roomId;
  bool _isEnding = false; // prevent multiple disposes

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _startCall();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> _startCall() async {
    signaling.onAddRemoteStream = (stream) {
      setState(() => _remoteRenderer.srcObject = stream);
    };

    await signaling.openUserMedia(_localRenderer);

    if (widget.isCaller) {
      _roomId = await signaling.createRoom(widget.currentUserId, widget.receiverId);
      _listenForReceiverResponse();
    } else {
      await signaling.joinRoom(widget.roomId!);
    }
  }

  void _listenForReceiverResponse() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.receiverId)
        .collection('incoming_call')
        .doc('active')
        .snapshots()
        .listen((snap) async {
      if (!snap.exists) return;
      final status = snap.data()?['status'];
      if (status == 'rejected') {
        await _endCallCleanup();
        if (mounted) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Call Rejected")),
        );
      }
    });
  }

  Future<void> _endCallCleanup() async {
    if (_isEnding) return;
    _isEnding = true;

    try {
      await signaling.hangUp(_roomId ?? widget.roomId!, widget.receiverId);
    } catch (_) {}

    await _disposeRenderersSafely();
  }

  /// ✅ SAFE RENDERER DISPOSAL (prevents Android Surface.release() crash)
  Future<void> _disposeRenderersSafely() async {
    try {
      _localRenderer.srcObject = null;
      _remoteRenderer.srcObject = null;

      await Future.delayed(const Duration(milliseconds: 100));

      if (_localRenderer.textureId != null) {
        await _localRenderer.dispose();
      }
      if (_remoteRenderer.textureId != null) {
        await _remoteRenderer.dispose();
      }
    } catch (e) {
      debugPrint("⚠️ Renderer dispose error: $e");
    }
  }

  void _hangUp() async {
    await _endCallCleanup();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _endCallCleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: RTCVideoView(
              _remoteRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          ),
          Positioned(
            right: 16,
            top: 40,
            child: SizedBox(
              width: 120,
              height: 160,
              child: RTCVideoView(
                _localRenderer,
                mirror: true,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                heroTag: 'webrtc_call_fab',
                backgroundColor: Colors.red,
                onPressed: _hangUp,
                child: const Icon(Icons.call_end),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
