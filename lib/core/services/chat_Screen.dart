import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final _fire = FirebaseFirestore.instance;

  saveMessage(Map<String , dynamic>message , String chatRoomId){
    try{
    _fire.collection("chatRoom").doc(chatRoomId).collection("messages").add(message);
    }
    catch(e){
      rethrow;
    }
}

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessage(String chatRoomId){
    return
    _fire.collection("chatRoom").doc(chatRoomId).collection("messages").orderBy("timeStamp",descending: false)
    .snapshots();
    

}
}