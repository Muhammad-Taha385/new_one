import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallScreen extends StatefulWidget {
  final String id;
  final String name;
  const CallScreen({super.key, required this.id, required this.name});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: 
        ZegoSendCallInvitationButton(
          // margin: EdgeInsets.all(0),
          // padding: EdgeInsets.all(0),
          isVideoCall: true,
          resourceID: "zegouikit_call",
          invitees: [
            ZegoUIKitUser(
              id: widget.id,
              name: widget.name,
            ),
          ],
          onPressed: (String code, String message, List<String> errorInvitees) {
            log('Invitation send result -- code: $code, msg: $message, errors: $errorInvitees');
            if (errorInvitees.isNotEmpty) {
              // handle error: show UI / log
              debugPrint('Failed invitees: $errorInvitees');
            }
          },
          // icon: ButtonIcon(
          //   icon: Icon(Icons.call, color: Colors.green, size: 22.h),
          //   backgroundColor: Colors.transparent,
          // ),
        ),
//         ZegoUIKitPrebuiltCall(
//   appID: yourAppID,
//   appSign: yourAppSign,
//   userID: FirebaseAuth.instance.currentUser!.uid,
//   callID: "call_${widget.id}_${DateTime.now().millisecondsSinceEpoch}",
//   config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
//   userName:FirebaseAuth.instance.currentUser!.displayName.toString() ,
// )
      ),
    );
  }
}
