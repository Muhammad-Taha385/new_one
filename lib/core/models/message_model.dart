import 'dart:convert';

class MessageModel {
  final String? id;
  final String? content;
  final String? senderId;
  final String? recieverId; 
  final DateTime? timeStamp;
  final bool? isRead;

  MessageModel({
    this.content,
    this.id,
    this.recieverId,
    this.senderId,
    this.timeStamp,
    this.isRead,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'content': content,
      'senderId': senderId,
      'recieverId': recieverId,
      'timeStamp': timeStamp?.microsecondsSinceEpoch,
      'isRead':isRead,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] != null ? map['id'] as String:null ,
      content: map['content'] != null ? map['content'] as String : null,
      senderId: map['senderId'] != null? map['senderId'] as String : null,
      recieverId: map['recieverId'] != null? map['recieverId'] as String : null,
      timeStamp: map['timeStamp'] != null
          ? DateTime.fromMicrosecondsSinceEpoch(map['timeStamp'] as int)
          : null,
      isRead: map['isRead'] == true,
    );
  }

  String toJson() => json.encode(toMap());

  factory MessageModel.fromJson(String source) =>
      MessageModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
  
  @override
  String toString(){
    return 'Message(id:$id ,content:$content ,senderId:$senderId ,recieverId:$recieverId ,timeStamp:$timeStamp)';
  }
}
// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class MessageModel {
//   final String? id;
//   final String? content;
//   final String? senderId;
//   final String? recieverId;
//   final DateTime? timeStamp;
//   final bool? isRead;

//   MessageModel({
//     this.id,
//     this.content,
//     this.senderId,
//     this.recieverId,
//     this.timeStamp,
//     this.isRead,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'content': content,
//       'senderId': senderId,
//       'recieverId': recieverId,
//       // 'timeStamp': timeStamp != null
//       //     ? Timestamp.fromDate(timeStamp!)
//       //     : FieldValue.serverTimestamp(),
//       'timeStamp':FieldValue.serverTimestamp(),
//       'isRead': isRead ?? false,
//     };
//   }

//   factory MessageModel.fromMap(Map<String, dynamic> map) {
//     return MessageModel(
//       id: map['id'] as String?,
//       content: map['content'] as String?,
//       senderId: map['senderId'] as String?,
//       recieverId: map['recieverId'] as String?,
//       timeStamp: map['timeStamp'] is Timestamp
//           ? (map['timeStamp'] as Timestamp).toDate()
//           : null,
//       isRead: map['isRead'] == true,
//     );
//   }

//   String toJson() => json.encode(toMap());

//   factory MessageModel.fromJson(String source) =>
//       MessageModel.fromMap(jsonDecode(source));

//   @override
//   String toString() {
//     return 'MessageModel(id: $id, content: $content, senderId: $senderId, recieverId: $recieverId, timeStamp: $timeStamp, isRead: $isRead)';
//   }
// }
