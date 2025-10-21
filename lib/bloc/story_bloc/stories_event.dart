abstract class StoryEvent {}

class UploadStory extends StoryEvent {
  final String uid;
  final String filePath;
  final String? text; // optional text story
  UploadStory(this.uid, this.filePath, {this.text});
}

class UploadTextStory extends StoryEvent {
  final String uid;
  final String text;
  UploadTextStory(this.uid, this.text);
}

class FetchAllStories extends StoryEvent {}
