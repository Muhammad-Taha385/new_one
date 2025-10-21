// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:real_time_chat_application/bloc/user_provider/user_provider_bloc.dart';
// import 'package:real_time_chat_application/bloc/user_provider/user_provider_event.dart';
// import 'package:real_time_chat_application/bloc/user_provider/user_provider_state.dart';
// // import 'package:real_time_chat_application/core/services/database_service.dart';
// import 'package:real_time_chat_application/ui/screens/bottom_navigation_bar/bottom_navigation_bar.dart';
// import 'package:real_time_chat_application/ui/screens/onBoardingScreen/onBoradingScreen.dart';

// class UserSessionHandling extends StatelessWidget {
//   const UserSessionHandling({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         final bloc = context.read<UserBloc>();
    
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
    
//         final user = snapshot.data;
    
//         if (user != null && user.emailVerified) {
//           // Fetch user only once when user logs in
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             bloc.add(FetchUser(user.uid));
//           });
    
//           return BlocBuilder<UserBloc, UserState>(
//             builder: (context, state) {
//               // if (state is UserLoading) {
//               //   return null;
//               //   // return const Center(child: CircularProgressIndicator());
//               // } 
//               if (state is UserLoaded) {
//                 return MyBottomNavigationBar();
//               } else if (state is UserError) {
//                 return Center(child: Text("Error: ${state.message}"));
//               } else {
//                 return const SizedBox();
//               }
//             },
//           );
//         } else {
//           bloc.add(ClearUser());
//           return const OnBoardingScreen();
//         }
//       },
//     );
//   }
// }

//NEW SCREEN 


// import 'dart:async';
// import 'dart:developer';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:real_time_chat_application/bloc/user_provider/user_provider_bloc.dart';
// import 'package:real_time_chat_application/bloc/user_provider/user_provider_event.dart';
// import 'package:real_time_chat_application/bloc/user_provider/user_provider_state.dart';
// import 'package:real_time_chat_application/core/models/usermodel.dart';
// import 'package:real_time_chat_application/ui/screens/bottom_navigation_bar/bottom_navigation_bar.dart';
// import 'package:real_time_chat_application/ui/screens/onBoardingScreen/onBoradingScreen.dart';

// // ⬇️ Import Zego dependencies
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
// import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

// // // Your Zego Cloud credentials (replace with your own)
// const int yourAppID = 800496072; // <-- Replace with your Zego appID
// const String yourAppSign = "0f30fd1526d8c53e9bbc66ebee4ba574cfeaa9a35675f37daac95282d3bf027c"; // <-- Replace with your Zego appSign

// // class UserSessionHandling extends StatefulWidget {
// //   const UserSessionHandling({super.key});

// //   @override
// //   State<UserSessionHandling> createState() => _UserSessionHandlingState();
// // }

// // class _UserSessionHandlingState extends State<UserSessionHandling> {
// //   bool _zegoInitialized = false;

// //   /// 🧩 Initialize Zego UIKit Call Invitation Service
// //   Future<void> _initializeZegoService(Usermodel user) async {
// //     if (_zegoInitialized) return; // Avoid reinitializing if already done
// //     _zegoInitialized = true;

// //     await 
// //     ZegoUIKitPrebuiltCallInvitationService().init(
// //       appID: yourAppID,
// //       appSign: yourAppSign,
// //       userID: user.uid,
// //       userName: user.name ?? user.email ?? "User",
// //       plugins: [ZegoUIKitSignalingPlugin()],
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return StreamBuilder<User?>(
// //       stream: FirebaseAuth.instance.authStateChanges(),
// //       builder: (context, snapshot) {
// //         final bloc = context.read<UserBloc>();

// //         if (snapshot.connectionState == ConnectionState.waiting) {
// //           return const Center(child: CircularProgressIndicator());
// //         }

// //         final user = snapshot.data;

// //         if (user != null && user.emailVerified) {
// //           // Fetch user and initialize Zego when logged in
// //           WidgetsBinding.instance.addPostFrameCallback((_) async {
// //             final currentUserDoc = await FirebaseFirestore.instance
// //             .collection("users")
// //             .doc(user.uid)
// //             .get();

// //             final currentUser = Usermodel.fromMap(currentUserDoc.data()!);

// //             bloc.add(FetchUser(currentUser.uid));
// //             await _initializeZegoService(currentUser);
// //           });

// //           return BlocBuilder<UserBloc, UserState>(
// //             builder: (context, state) {
// //               if (state is UserLoaded) {
// //                 return MyBottomNavigationBar();
// //               } else if (state is UserError) {
// //                 return Center(child: Text("Error: ${state.message}"));
// //               } else {
// //                 return const SizedBox();
// //               }
// //             },
// //           );
// //         } else {
// //           bloc.add(ClearUser());

// //           /// Stop the Zego service when user logs out
// //           if (_zegoInitialized) {
// //             ZegoUIKitPrebuiltCallInvitationService().uninit();
// //             _zegoInitialized = false;
// //           }

// //           return const OnBoardingScreen();
// //         }
// //       },
// //     );
// //   }
// // }

// // nEW nEW SCREEN

// class UserSessionHandling extends StatefulWidget {
//   const UserSessionHandling({super.key});

//   @override
//   State<UserSessionHandling> createState() => _UserSessionHandlingState();
// }

// class _UserSessionHandlingState extends State<UserSessionHandling> {
//   bool _zegoInitialized = false;
//   StreamSubscription<User?>? _authSub;

//   @override
//   void initState() {
//     super.initState();

   
//     _authSub = FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
//       final bloc = context.read<UserBloc>();
//       if (firebaseUser != null && firebaseUser.emailVerified) {
//         try {
          
//           final currentUserDoc = await FirebaseFirestore.instance.collection("users").doc(firebaseUser.uid).get();
//           final currentUser = Usermodel.fromMap(currentUserDoc.data()!);
//           bloc.add(FetchUser(currentUser.uid));

         
//           await _initializeZegoService(currentUser);
//         } catch (e, st) {
//           debugPrint('Error initializing after login: $e\n$st');
//         }
//       } else {
        
//         bloc.add(ClearUser());
//         if (_zegoInitialized) {
//           ZegoUIKitPrebuiltCallInvitationService().uninit();
//           _zegoInitialized = false;
//           debugPrint('Zego uninitialized (user logged out)');
//         }
//       }
//     });
//   }

//   Future<void> _initializeZegoService(Usermodel user) async {
//     if (_zegoInitialized) return;
//     try {
//       debugPrint('Starting Zego init for ${user.uid}...');
//       await 
//       ZegoUIKitPrebuiltCallInvitationService().init(

//         appID: yourAppID,
//         appSign: yourAppSign,
//         userID: user.uid,
//         userName: user.name ?? user.email ?? 'User',
//         plugins: [ZegoUIKitSignalingPlugin()],

//       );
      
//       _zegoInitialized = true;
//       log('Zego init successful for ${user.uid}');
//     } catch (e, st) {
//       _zegoInitialized = false;
//       log('Zego init failed: $e\n$st');
//       rethrow;
//     }
//   }

//   @override
//   void dispose() {
//     _authSub?.cancel();
//     if (_zegoInitialized) {
//       ZegoUIKitPrebuiltCallInvitationService().uninit();
//       _zegoInitialized = false;
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         final bloc = context.read<UserBloc>();
//         if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

//         final user = snapshot.data;
//         if (user != null && user.emailVerified) {
//           return BlocBuilder<UserBloc, UserState>(builder: (context, state) {
//             if (state is UserLoaded) return MyBottomNavigationBar();
//             if (state is UserError) return Center(child: Text("Error: ${state.message}"));
//             return const SizedBox();
//           });
//         } else {
//           bloc.add(ClearUser());
//           return const OnBoardingScreen();
//         }
//       },
//     );
//   }
// }


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_time_chat_application/bloc/user_provider/user_provider_bloc.dart';
import 'package:real_time_chat_application/bloc/user_provider/user_provider_event.dart';
import 'package:real_time_chat_application/bloc/user_provider/user_provider_state.dart';
import 'package:real_time_chat_application/ui/screens/bottom_navigation_bar/bottom_navigation_bar.dart';
import 'package:real_time_chat_application/ui/screens/onBoardingScreen/onBoradingScreen.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class UserSessionHandling extends StatefulWidget {
  const UserSessionHandling({super.key});

  @override
  State<UserSessionHandling> createState() => _UserSessionHandlingState();
}

class _UserSessionHandlingState extends State<UserSessionHandling> {
  bool _isZegoInitialized = false;

  @override
  void dispose() {
    // ✅ Deinitialize Zego service when widget is disposed (user logs out or app closes)
    ZegoUIKitPrebuiltCallInvitationService().uninit();
    super.dispose();
  }

  Future<void> _initZegoService(User user) async {
    // 🔹 Replace with your real values
    const int appID = 800496072;
    const String appSign = '0f30fd1526d8c53e9bbc66ebee4ba574cfeaa9a35675f37daac95282d3bf027c';

    await ZegoUIKitPrebuiltCallInvitationService().init(
      appID: appID,
      appSign: appSign,
      userID: user.uid,
      userName: user.displayName ?? user.email ?? "User",
      plugins: [ZegoUIKitSignalingPlugin()],
      // config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),


    );

    debugPrint("✅ Zego Call Service initialized for ${user.uid}");
      debugPrint('Zego init() returned — now waiting for signaling connected');

  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final bloc = context.read<UserBloc>();

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;

        if (user != null && user.emailVerified) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            bloc.add(FetchUser(user.uid));

            // ✅ Initialize Zego service only once
            if (!_isZegoInitialized) {
              // await Future.delayed(const Duration(seconds: 2));
              await _initZegoService(user);
              setState(() => _isZegoInitialized = true);
            }
          });

          return BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              if (state is UserLoaded) {
                return MyBottomNavigationBar();
              } else if (state is UserError) {
                return Center(child: Text("Error: ${state.message}"));
              } else {
                return const SizedBox();
              }
            },
          );
        } else {
          bloc.add(ClearUser());
          // ✅ Cleanup Zego service on logout
          if (_isZegoInitialized) {
            ZegoUIKitPrebuiltCallInvitationService().uninit();
            _isZegoInitialized = false;
          }
          return const OnBoardingScreen();
        }
      },
    );
  }
}
