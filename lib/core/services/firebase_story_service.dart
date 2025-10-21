import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:real_time_chat_application/core/models/stories_model.dart';

class FirestoreStoryService {
  final _db = FirebaseFirestore.instance;

  Future<void> addStory(StoriesModel story) async {
    await _db.collection("stories").add(story.toMap());
  }

  Stream<List<StoriesModel>> getUserStories(String uid) {
    return _db
        .collection("stories")
        .where("fromUid", isEqualTo: uid)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StoriesModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<StoriesModel>> getAllStories() {
    return _db
        .collection("stories")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StoriesModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
