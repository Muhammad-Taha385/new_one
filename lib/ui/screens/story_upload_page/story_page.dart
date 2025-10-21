import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:real_time_chat_application/bloc/story_bloc/stories_bloc.dart';
import 'package:real_time_chat_application/bloc/story_bloc/stories_event.dart';
import 'package:real_time_chat_application/bloc/story_bloc/stories_state.dart';
import 'package:real_time_chat_application/core/constants/strings.dart';
import 'package:real_time_chat_application/core/models/stories_model.dart';
// import 'package:real_time_chat_application/core/utils/new_route_utils.dart';
import 'package:real_time_chat_application/core/utils/route_utils.dart';
import 'story_viewer_page.dart';

class StoryPage extends StatefulWidget {
  const StoryPage({super.key});

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage>
    with AutomaticKeepAliveClientMixin {
  final currentUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    // ✅ Only fetch stories once
    context.read<StoryBloc>().add(FetchAllStories());
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for keep-alive mixin

    return Scaffold(
      appBar: AppBar(title: const Text("Status")),
      body: BlocBuilder<StoryBloc, StoryState>(
        builder: (context, state) {
          if (state is StoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StoryError) {
            return Center(child: Text("Error: ${state.error}"));
          } else if (state is StoryLoaded) {
            final myStories =
                state.stories.where((s) => s.fromUid == currentUid).toList();
            final friendStories =
                state.stories.where((s) => s.fromUid != currentUid).toList();

            return RefreshIndicator(
              onRefresh: () async {
                context.read<StoryBloc>().add(FetchAllStories());
              },
              child: ListView(
                children: [
                  _myStatusSection(context, myStories, currentUid),
                  const Divider(thickness: 1),
                  _friendStatusSection(context, friendStories),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _myStatusSection(
      BuildContext context, List<StoriesModel> myStories, String uid) {
    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.grey.shade400,
        backgroundImage: myStories.isNotEmpty &&
                myStories.first.mediaUrl.isNotEmpty
            ? NetworkImage(myStories.first.mediaUrl)
            : null,
        child: myStories.isEmpty
            ? const Icon(Icons.person, size: 30, color: Colors.white)
            : null,
      ),
      title: const Text("My Status",
          style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        myStories.isEmpty
            ? "Tap to add a status update"
            : "You have ${myStories.length} stor${myStories.length > 1 ? 'ies' : 'y'}",
      ),
      onTap: () {
        if (myStories.isEmpty) {
          navigationService.pushNamed(storyview);
        } else {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.remove_red_eye_outlined),
                    title: const Text("View My Status"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StoryViewerPage(stories: myStories),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.add_circle_outline),
                    title: const Text("Add New Status"),
                    onTap: () {
                      Navigator.pop(context);
                      navigationService.pushNamed(storyview);
                    },
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _friendStatusSection(
      BuildContext context, List<StoriesModel> friendStories) {
    if (friendStories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text("No stories from your friends yet."),
        ),
      );
    }

    final Map<String, List<StoriesModel>> groupedStories = {};
    for (final story in friendStories) {
      groupedStories.putIfAbsent(story.fromUid, () => []).add(story);
    }

    groupedStories.forEach((key, stories) {
      stories.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Recent updates",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        ...groupedStories.entries.map((entry) {
          final userId = entry.key;
          final userStories = entry.value;
          final latestStory = userStories.first;

          return ListTile(
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.teal,
              backgroundImage: latestStory.mediaUrl.isNotEmpty
                  ? NetworkImage(latestStory.mediaUrl)
                  : null,
              child: latestStory.mediaUrl.isEmpty
                  ? const Icon(Icons.text_fields, color: Colors.white)
                  : null,
            ),
            title: Text(userId, overflow: TextOverflow.ellipsis),
            subtitle: Text(
              "Posted ${_formatTimeAgo(latestStory.timeStamp)}",
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StoryViewerPage(stories: userStories),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  String _formatTimeAgo(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else {
      return "${difference.inDays}d ago";
    }
  }
}
