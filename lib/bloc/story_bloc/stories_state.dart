
import 'package:real_time_chat_application/core/models/stories_model.dart';

abstract class StoryState {}

class StoryInitial extends StoryState {}
class StoryLoading extends StoryState {}
class StoryUploaded extends StoryState {}
class StoryError extends StoryState {
  final String error;
  StoryError(this.error);
}
class StoryLoaded extends StoryState {
  final List<StoriesModel> stories;
  StoryLoaded(this.stories);
}
