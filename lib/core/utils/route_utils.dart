import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:real_time_chat_application/core/constants/strings.dart';
import 'package:real_time_chat_application/core/models/usermodel.dart';
import 'package:real_time_chat_application/ui/screens/auth/login/loginn_screen.dart';
import 'package:real_time_chat_application/ui/screens/auth/signup/signup_screen.dart';
import 'package:real_time_chat_application/ui/screens/chatroom/chat_room.dart';
// import 'package:real_time_chat_application/ui/screens/home/home_screen.dart';
import 'package:real_time_chat_application/ui/screens/contact_screen/contact_screen.dart';
import 'package:real_time_chat_application/ui/screens/splash/splash_screen.dart';
import 'package:real_time_chat_application/ui/screens/story_upload_page/story_upload_page.dart';
import 'package:real_time_chat_application/ui/screens/wrapper/new_wrapper.dart';
import 'package:real_time_chat_application/ui/screens/wrapper/wrapper.dart';
// import 'package:flutter_application_1/models/order_model.dart';
// import 'package:flutter_application_1/views/customer_dashboard.dart';
// import 'package:flutter_application_1/views/customer_order_detail.dart';
// import 'package:flutter_application_1/views/login.dart';
// import 'package:flutter_application_1/views/profile_screen.dart';
// import 'package:flutter_application_1/views/splash_screen.dart';

// import 'route_names.dart';

class NavigationService extends NavigatorObserver {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final NavigationService _instance = NavigationService._internal();
  NavigationService._internal();

  factory NavigationService() => _instance;

  List history = [];
  dynamic pushNamed(String route, {dynamic arguments}) {
    history.add(route);
    return navigatorKey.currentState?.pushNamed(route, arguments: arguments);
  }

  dynamic pop() {
    if (history.isNotEmpty) {
      history.removeLast();
    }
    return navigatorKey.currentState?.pop();
  }

  dynamic pushNamedAndRemoveUntil(String route) {
    history = [];
    return navigatorKey.currentState?.pushNamedAndRemoveUntil(
      route,
      ModalRoute.withName('/'),
    );
  }

  // dynamic popUntils(bool Function(Route<dynamic>) route, {dynamic arguments}) {
  //   history = [];
  //   return navigatorKey.currentState?.popUntil(route);
  // }
}

class RouteGenerator {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";

    final args = settings.arguments;

    switch (settings.name) {
      case wrapper:
        return MaterialPageRoute(
          builder: (_) => const UserSessionHandling(),
        );

      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      // case home:
      //   // final data = args as Map<String, dynamic>;

      //   return MaterialPageRoute(
      //     builder: (_) => const HomeScreen(
      //         // currentUser: data['currentUser'] as Usermodel,
      //         ),
      //   );

      case signup:
        return MaterialPageRoute(
          builder: (_) => const SignupScreen(),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => LoginScreen(),
        );

      case contacts:
        return MaterialPageRoute(
            builder: (_) => ContactScreen(currentUserId: currentUid));
      case chatRoom:
        final data = args as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ChatRoom(
            currentUser: data['currentUser'] as Usermodel,
            // currentUser: Usermodel,
            // currentUser: Usermodel,
            receiver: data['receiver'] as Usermodel,
          ),
        );

      case storyview:
        return MaterialPageRoute(
            builder: (_) => StoryUploadPage(currentUid: currentUid));

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("No Route Found")),
          ),
        );
    }
  }
}

NavigationService navigationService = NavigationService();
