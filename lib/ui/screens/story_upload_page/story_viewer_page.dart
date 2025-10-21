import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';
import 'package:real_time_chat_application/core/models/stories_model.dart';

class StoryViewerPage extends StatefulWidget {
  final List<StoriesModel> stories;
  const StoryViewerPage({super.key, required this.stories});

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage> {
  final StoryController _controller = StoryController();
  late final List<StoryItem> _storyItems;

  @override
  void initState() {
    super.initState();
    _storyItems = widget.stories.map((story) {
      if (story.mediaUrl.isNotEmpty) {
        return StoryItem.pageImage(
          url: story.mediaUrl,
          controller: _controller,
          caption: story.text != null && story.text!.isNotEmpty
              ? Text(
                  story.text!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                  ),
                )
              : null,
        );
      } else {
        return StoryItem.text(
          title: story.text ?? "",
          backgroundColor: Colors.black,
          textStyle: const TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        );
      }
    }).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            StoryView(
              storyItems: _storyItems,
              controller: _controller,
              onComplete: () => Navigator.pop(context),
              onVerticalSwipeComplete: (direction) {
                if (direction == Direction.down) Navigator.pop(context);
              },
            ),
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
