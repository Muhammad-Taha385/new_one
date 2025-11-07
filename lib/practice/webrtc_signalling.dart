import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      {'urls': 'stun:stun.relay.metered.ca:80'},
      {
        'urls': 'turn:turn.relay.metered.ca:80',
        'username': 'openrelayproject',
        'credential': 'openrelayproject'
      },
    ]
  };

  /// 🔹 Open camera and mic
  Future<void> openUserMedia(RTCVideoRenderer localRenderer) async {
    final stream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });
    localRenderer.srcObject = stream;
    _localStream = stream;
  }

  /// 🔹 Create Room (Caller)
  Future<String> createRoom(String callerId, String receiverId) async {
    _peerConnection = await createPeerConnection(_iceServers);
    _registerPeerConnectionListeners();

    // Add tracks from local stream
    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    final roomRef = _firestore.collection('rooms').doc();
    final callerCandidates = roomRef.collection('callerCandidates');

    _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      callerCandidates.add(candidate.toMap());
    };

    _peerConnection?.onAddStream = (stream) {
      onAddRemoteStream?.call(stream);
    };

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    await roomRef.set({
      'offer': offer.toMap(),
      'callerId': callerId,
      'receiverId': receiverId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 🔔 Notify receiver of the incoming call
    await _firestore
        .collection('users')
        .doc(receiverId)
        .collection('incoming_call')
        .doc('active')
        .set({
      'roomId': roomRef.id,
      'callerId': callerId,
      'isVideo': true,
    });

    log("Room created with ID: ${roomRef.id}");

    // 🔹 Listen for remote answer
    roomRef.snapshots().listen((snapshot) async {
      final data = snapshot.data();
      if (data != null && data['answer'] != null) {
        final answer = data['answer'];
        final remoteDesc = RTCSessionDescription(answer['sdp'], answer['type']);

        // ✅ Use async getter for remote description
        final currentRemote = await _peerConnection?.getRemoteDescription();
        if (currentRemote == null) {
          await _peerConnection?.setRemoteDescription(remoteDesc);
          log("Remote description set from callee ✅");
        }
      }
    });

    // 🔹 Listen for callee ICE candidates
    roomRef.collection('calleeCandidates').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data()!;
          _peerConnection?.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
          log("Added remote ICE candidate from callee ✅");
        }
      }
    });

    return roomRef.id;
  }

  /// 🔹 Join Room (Callee)
  Future<void> joinRoom(String roomId) async {
    final roomRef = _firestore.collection('rooms').doc(roomId);
    final snapshot = await roomRef.get();

    if (!snapshot.exists) throw Exception("Room not found!");

    _peerConnection = await createPeerConnection(_iceServers);
    _registerPeerConnectionListeners();

    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    final calleeCandidates = roomRef.collection('calleeCandidates');

    _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      calleeCandidates.add(candidate.toMap());
    };

    _peerConnection?.onAddStream = (stream) {
      onAddRemoteStream?.call(stream);
    };

    final data = snapshot.data()!;
    final offer = data['offer'];
    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(offer['sdp'], offer['type']),
    );

    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    await roomRef.update({'answer': answer.toMap()});

    // Listen for caller ICE candidates
    roomRef.collection('callerCandidates').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data()!;
          _peerConnection?.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        }
      }
    });
  }

  void _registerPeerConnectionListeners() {
    _peerConnection?.onConnectionState = (state) {
      log("Connection State: $state");
    };
  }

  /// 🔹 End call
  Future<void> hangUp(String roomId, String receiverId) async {
    await _localStream?.dispose();
    await _peerConnection?.close();

    await _firestore
        .collection('users')
        .doc(receiverId)
        .collection('incoming_call')
        .doc('active')
        .delete()
        .catchError((_) {});

    _peerConnection = null;
    _localStream = null;
  }
}
