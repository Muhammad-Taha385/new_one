import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:real_time_chat_application/bloc/story_bloc/stories_event.dart';
import 'package:real_time_chat_application/bloc/story_bloc/stories_state.dart';
import 'package:real_time_chat_application/core/models/stories_model.dart';
import 'package:real_time_chat_application/core/models/usermodel.dart';
import 'package:real_time_chat_application/core/services/database_service.dart';
import 'package:real_time_chat_application/core/services/firebase_story_service.dart';

class StoryBloc extends Bloc<StoryEvent, StoryState> {
  final FirestoreStoryService _storyService;
  final DatabaseService _db;

  StoryBloc({
    FirestoreStoryService? storyService,
    DatabaseService? databaseService,
  })  : _storyService = storyService ?? FirestoreStoryService(),
        _db = databaseService ?? DatabaseService(),
        super(StoryInitial()) {
    on<UploadStory>(_uploadStory);
    on<UploadTextStory>(_uploadTextStory);
    on<FetchAllStories>(_fetchAllStories);
  }

  /// ✅ Handles image upload story
  Future<void> _uploadStory(
      UploadStory event, Emitter<StoryState> emit) async {
    emit(StoryLoading());

    const cloudName = "dudf7hn2n";
    const uploadPreset = "flutter_upload";
    final uploadUrl =
        Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/upload");

    try {
      final request = http.MultipartRequest("POST", uploadUrl)
        ..fields["upload_preset"] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath("file", event.filePath));

      final response = await request.send();
      final resBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(resBody);

      if (response.statusCode == 200) {
        final imageUrl = jsonResponse["secure_url"];
        final story = StoriesModel(
          fromUid: event.uid,
          mediaUrl: imageUrl,
          text: event.text ?? "",
          status: "active",
          timeStamp: DateTime.now(),
          toUids: await _toUids(),
        );

        await _storyService.addStory(story);
        if (!emit.isDone) emit(StoryUploaded());
      } else {
        if (!emit.isDone) {
          emit(StoryError("Upload failed: ${jsonResponse.toString()}"));
        }
      }
    } catch (e) {
      if (!emit.isDone) emit(StoryError(e.toString()));
    }
  }

  /// ✅ Handles text-only story
  Future<void> _uploadTextStory(
      UploadTextStory event, Emitter<StoryState> emit) async {
    emit(StoryLoading());
    try {
      final story = StoriesModel(
        fromUid: event.uid,
        mediaUrl: "",
        text: event.text,
        status: "active",
        timeStamp: DateTime.now(),
        toUids: await _toUids(),
      );

      await _storyService.addStory(story);
      if (!emit.isDone) emit(StoryUploaded());
    } catch (e) {
      if (!emit.isDone) emit(StoryError(e.toString()));
    }
  }

  /// ✅ Fetches all stories (stream)
  Future<void> _fetchAllStories(
      FetchAllStories event, Emitter<StoryState> emit) async {
    emit(StoryLoading());
    try {
      await emit.forEach<List<StoriesModel>>(
        _storyService.getAllStories(),
        onData: (stories) => StoryLoaded(stories),
        onError: (error, stackTrace) => StoryError(error.toString()),
      );
    } catch (e) {
      if (!emit.isDone) emit(StoryError(e.toString()));
    }
  }

  /// ✅ Fetches all friends UIDs
  Future<List<String>> _toUids() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final List<Usermodel> friends = await _db.fetchfriendsContacts(uid);
    return friends.map((user) => user.uid).toList();
  }
}
