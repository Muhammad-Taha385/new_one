import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path/path.dart';
import 'package:real_time_chat_application/bloc/bottom_navigation_bar/bottom_navigation_bar_bloc.dart';
import 'package:real_time_chat_application/bloc/contact_model_bloc.dart/contact_model_bloc.dart';
import 'package:real_time_chat_application/bloc/file_picker_bloc/file_picker_bloc.dart';
import 'package:real_time_chat_application/bloc/login_bloc/login_screen_bloc.dart';
import 'package:real_time_chat_application/bloc/signup_bloc/signup_bloc.dart';
import 'package:real_time_chat_application/bloc/story_bloc/stories_bloc.dart';
import 'package:real_time_chat_application/bloc/text_field_bloc/text_field_bloc.dart';
import 'package:real_time_chat_application/bloc/user_provider/user_provider_bloc.dart';
import 'package:real_time_chat_application/core/services/database_service.dart';
import 'package:real_time_chat_application/core/services/google_auth_service.dart';
import 'package:real_time_chat_application/core/services/image_picker_service.dart';
import 'package:real_time_chat_application/core/services/login_auth_service.dart';
import 'package:real_time_chat_application/core/services/signin_auth_service.dart';
// import 'package:real_time_chat_application/core/utils/new_route_utils.dart';
import 'package:real_time_chat_application/core/utils/route_utils.dart';
// import 'package:real_time_chat_application/core/utils/route_utils.dart';
import 'package:real_time_chat_application/firebase_options.dart';
import 'package:real_time_chat_application/practice/webrtc_callscreen.dart';
import 'package:real_time_chat_application/ui/screens/splash/splash_screen.dart';
// import 'package:zego_uiki/zego_uiki.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
// final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  ZegoUIKitPrebuiltCallInvitationService()
      .setNavigatorKey(navigationService.navigatorKey);

  await ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
    [ZegoUIKitSignalingPlugin()],
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // final GlobalKey<NavigatorState> navigatorKey;
  // final orientation = MediaQuery.of(context).orientation;
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => TextFieldBloc()),
        BlocProvider(
            create: (_) => LoginScreenBloc(
                LoginAuthService(), GoogleAuthService(), DatabaseService())),
        BlocProvider(
            create: (_) => SignupBloc(SignupAuthService(), DatabaseService())),
        BlocProvider(create: (_) => BottomNavigationBarBloc()),
        BlocProvider(create: (_) => UserBloc(DatabaseService())),
        BlocProvider(create: (_) => ContactBloc(DatabaseService())),
        BlocProvider(create: (_) => StoryBloc()),
        BlocProvider(create: (_) => ImagePickerBloc(ImagePickerUtils()))
      ],
      child: ScreenUtilInit(
        // designSize: const Size(375, 812),
        designSize: orientation == Orientation.portrait
            ? const Size(375, 750)
            : const Size(812, 375),
        minTextAdapt: true, // ensures text stays readable
        splitScreenMode: true,
        useInheritedMediaQuery: true,

        builder: (context, child) => MaterialApp(
          // navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          // onGenerateRoute: RouteUtils.onGenerateRoute,
          onGenerateRoute: RouteGenerator.onGenerateRoute,
          // initialRoute: RouteNames.dashboard,
          initialRoute: '/',
          navigatorKey: navigationService.navigatorKey,

          navigatorObservers: [NavigationService()],
          home:SplashScreen() ,
        ),
      ),
    );
  }
}
