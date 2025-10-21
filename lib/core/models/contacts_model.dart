import 'package:cloud_firestore/cloud_firestore.dart';

class ContactModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String status; // pending, accepted, rejected
  final DateTime createdAt;

  ContactModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
  });

  factory ContactModel.fromMap(Map<String, dynamic> map, String docId) {
    return ContactModel(
      id: docId,
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      status: map['status'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status,
      'createdAt': createdAt,
    };
  }

  
}
