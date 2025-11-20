import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

typedef StreamCallback = void Function(MediaStream stream);

/// ---------------- Audio Signaling (Audio-only) ----------------
class AudioSignaling {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  StreamCallback? onAddRemoteStream;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun1.l.google.com:19302'},
    ]
  };

  /// Open microphone only
  Future<void> openUserMedia() async {
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': false, // explicit audio-only
    });
  }

  /// Create peer connection with audio-only track
  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection(_iceServers);

    _peerConnection?.onConnectionState = (state) => log('Connection: $state');
    _peerConnection?.onIceConnectionState = (state) => log('ICE: $state');

    _peerConnection?.onTrack = (RTCTrackEvent event) {
      if (event.track.kind == 'audio' && event.streams.isNotEmpty) {
        onAddRemoteStream?.call(event.streams[0]);
      }
    };
  }

  /// Create room (caller)
  Future<String> createRoom(String callerId, String receiverId) async {
    if (_localStream == null) throw Exception('Local stream not opened');
    await _createPeerConnection();

    // Add only audio tracks
    _localStream!.getAudioTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

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
      'callType': 'audio',
      'status': 'ringing',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('users').doc(receiverId).collection('incoming_call').doc('active').set({
      'roomId': roomRef.id,
      'callerId': callerId,
      'callType': 'audio',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Listen for answer
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

    // Listen for callee ICE candidates
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

  /// Join room (callee)
  Future<void> joinRoom(String roomId, {String? receiverUserId}) async {
    final roomRef = _firestore.collection('rooms').doc(roomId);
    final snapshot = await roomRef.get();
    if (!snapshot.exists) throw Exception('Room not found');

    await _createPeerConnection();

    // Add only audio tracks
    _localStream!.getAudioTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

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

    // Listen for caller ICE candidates
    roomRef.collection('callerCandidates').snapshots().listen((snap) {
      for (var change in snap.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final d = change.doc.data()!;
          _peerConnection?.addCandidate(RTCIceCandidate(d['candidate'], d['sdpMid'], d['sdpMLineIndex']));
        }
      }
    });
  }

  /// Hang up
  Future<void> hangUp(String? roomId, {String? receiverId}) async {
    await _localStream?.dispose();
    await _peerConnection?.close();

    if (receiverId != null) {
      await _firestore.collection('users').doc(receiverId).collection('incoming_call').doc('active').delete().catchError((_) {});
    }

    if (roomId != null) {
      final roomRef = _firestore.collection('rooms').doc(roomId);
      try {
        for (var doc in (await roomRef.collection('callerCandidates').get()).docs) await doc.reference.delete();
        for (var doc in (await roomRef.collection('calleeCandidates').get()).docs) await doc.reference.delete();
        await roomRef.delete();
      } catch (e) {
        log('Cleanup error: $e');
      }
    }

    _localStream = null;
    _peerConnection = null;
  }

  /// Toggle mic
  void toggleMic() {
    if (_localStream != null) {
      final track = _localStream!.getAudioTracks().first;
      track.enabled = !track.enabled;
    }
  }
}

/// ---------------- Audio Call Screen ----------------
class AudioCallScreen extends StatefulWidget {
  final String currentUserId, currentUserName, receiverId, receiverName;
  final bool isCaller;
  final String? roomId;

  const AudioCallScreen({
    super.key,
    required this.currentUserId,
    required this.currentUserName,
    required this.receiverId,
    required this.receiverName,
    required this.isCaller,
    this.roomId,
  });

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  final AudioSignaling signaling = AudioSignaling();
  String? _roomId;
  bool _isMicMuted = false;

  @override
  void initState() {
    super.initState();
    _startCall();
  }

  Future<void> _startCall() async {
    await signaling.openUserMedia();
    if (widget.isCaller) {
      _roomId = await signaling.createRoom(widget.currentUserId, widget.receiverId);
    } else {
      if (widget.roomId == null) throw Exception('roomId required');
      _roomId = widget.roomId;
      await signaling.joinRoom(widget.roomId!, receiverUserId: widget.currentUserId);
    }
  }

  void _toggleMic() {
    setState(() => _isMicMuted = !_isMicMuted);
    signaling.toggleMic();
  }

  Future<void> _endCall() async {
    await signaling.hangUp(_roomId, receiverId: widget.receiverId);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.call, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            Text('Talking with ${widget.receiverName}', style: const TextStyle(color: Colors.white, fontSize: 22)),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: _isMicMuted ? Colors.red : Colors.white,
                  child: IconButton(
                    icon: Icon(_isMicMuted ? Icons.mic_off : Icons.mic, color: _isMicMuted ? Colors.white : Colors.black),
                    onPressed: _toggleMic,
                  ),
                ),
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.red,
                  child: IconButton(
                    icon: const Icon(Icons.call_end, color: Colors.white),
                    onPressed: _endCall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- Incoming Audio Call Screen ----------------
class IncomingAudioCallScreen extends StatelessWidget {
  final String currentUserId, currentUserName, callerId, callerName, roomId;

  const IncomingAudioCallScreen({
    super.key,
    required this.currentUserId,
    required this.currentUserName,
    required this.callerId,
    required this.callerName,
    required this.roomId,
  });

  Future<void> _acceptCall(BuildContext context) async {
    final userCallDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('incoming_call')
        .doc('active');
    await userCallDoc.update({'status': 'accepted'}).catchError((_) {});

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AudioCallScreen(
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
    final userCallDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('incoming_call')
        .doc('active');
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
            const Icon(Icons.call, size: 80, color: Colors.white),
            const SizedBox(height: 30),
            Text('$callerName is calling…', style: const TextStyle(color: Colors.white, fontSize: 22)),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: 'reject',
                  backgroundColor: Colors.red,
                  onPressed: () => _rejectCall(context),
                  child: const Icon(Icons.call_end),
                ),
                FloatingActionButton(
                  heroTag: 'accept',
                  backgroundColor: Colors.green,
                  onPressed: () => _acceptCall(context),
                  child: const Icon(Icons.call),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
