import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_time_chat_application/bloc/user_provider/user_provider_bloc.dart';
import 'package:real_time_chat_application/bloc/user_provider/user_provider_event.dart';
import 'package:real_time_chat_application/bloc/user_provider/user_provider_state.dart';
import 'package:real_time_chat_application/ui/screens/auth/login/loginn_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              auth.signOut().then((value) {
                context.read<UserBloc>().add(ClearUser());

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              }).onError((error, stackTrace) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error.toString()),
                    backgroundColor: Colors.grey.shade900,
                  ),
                );
                // Utilities.showToast(message: error.toString());
              });
            },
            icon: const Icon(Icons.logout_outlined),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserInitial) {
                  // trigger fetch if user is signed in
                  final uid = auth.currentUser?.uid;
                  // log("User uid Found $uid");
                  if (uid != null) {
                    context.read<UserBloc>().add(FetchUser(uid));
                    // log("Fetch User Event Found");
                  }
                  return const CircularProgressIndicator();
                } else if (state is UserLoading) {
                  return const CircularProgressIndicator();
                } else if (state is UserLoaded) {
                  // log("User Loaded");
                  // log("${state.user.name}");
                  return Text("Welcome, ${state.user.name}");
                } else if (state is UserError) {
                  // log("${state.message}");
                  return Text("Error: ${state.message}");
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
