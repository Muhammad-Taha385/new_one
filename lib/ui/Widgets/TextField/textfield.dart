// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:real_time_chat_application/bloc/text_field_bloc/text_field_bloc.dart';
// import 'package:real_time_chat_application/bloc/text_field_bloc/text_field_event.dart';
// import 'package:real_time_chat_application/core/constants/colors.dart';
// // class CustomTextField extends StatefulWidget {
// //   const CustomTextField({
// //     super.key,
// //     // required this.color,
// //     this.isChat = false,
// //     this.hintText,
// //     this.onChanged,
// //     this.focusNode,
// //     this.controller,
// //     this.prefixIcon,
// //     this.isObscure = false, // default to false
// //     this.validate,
// //     this.isSearch = false ,
// //     // this.messageController,
// //   });

// //   final String? hintText;
// //   final void Function(String)? onChanged;
// //   final FocusNode? focusNode;
// //   final TextEditingController? controller;
// //   final Icon? prefixIcon;
// //   final bool isObscure;
// //   final String? Function(String?)? validate;
// //   final bool isSearch ;
// //   final bool isChat;
// //   // final TextEditingController? messageController ;

// //   @override
// //   State<CustomTextField> createState() => _CustomTextFieldState();
// // }

// // class _CustomTextFieldState extends State<CustomTextField> {
// //   late bool _obscureText;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _obscureText = widget.isObscure;
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // bool isChat;
// //     return SizedBox(
// //       height: widget.isChat?40.h:null,
// //       // width: ,
// //       child: Padding(
// //         padding: EdgeInsets.symmetric(horizontal: 6.w),
// //         child: TextFormField(

// //           validator: widget.validate,
// //           obscureText: _obscureText,
// //           controller: widget.controller,
// //           onChanged: widget.onChanged,
// //           focusNode: widget.focusNode,
// //           decoration: InputDecoration(
// //             contentPadding: widget.isChat? EdgeInsets.symmetric(horizontal: 12.w):null,
// //             // focusedBorder: Colors.black,
// //             // focusColor: Colors.black,
// //             prefixIcon: widget.prefixIcon,
// //             suffixIcon: widget.isObscure
// //                 ? IconButton(
// //                     icon: Icon(
// //                       _obscureText ? Icons.visibility_off : Icons.visibility,
// //                       color: Colors.grey,
// //                     ),
// //                     onPressed: () {
// //                       setState(() {
// //                         _obscureText = !_obscureText;
// //                       });
// //                     },
// //                   )
// //                 : null,
// //             hintText: widget.hintText,
// //             hintStyle: const TextStyle(
// //               fontWeight: FontWeight.w300,
// //               fontSize: 14,
// //             ),
// //             filled: true,
// //             fillColor:widget.isChat? Colors.white : grey.withOpacity(0.12),
// //           //   enabledBorder: OutlineInputBorder(
// //           //   borderSide: BorderSide(color: Colors.grey.shade600),
// //           //   borderRadius: BorderRadius.circular(10.r),
// //           // ),
// //           // focusedBorder: OutlineInputBorder(
// //           //   borderSide: BorderSide(color: Colors.grey.shade600, width: 1.5),
// //           //   borderRadius: BorderRadius.circular(10.r),
// //           // ),
// //             border: OutlineInputBorder(
// //               borderSide: BorderSide.none,
// //               borderRadius: BorderRadius.circular(widget.isChat?20.r:10.r),

// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// class CustomTextField extends StatefulWidget {
//   const CustomTextField({
//     super.key,
//     // required this.color,
//     this.isChat = false,
//     this.hintText,
//     this.onChanged,
//     this.focusNode,
//     this.controller,
//     this.prefixIcon,
//     this.isObscure = false, // default to false
//     this.validate,
//     this.isSearch = false,
//     this.labelText,
//     this.filled,
//     this.labelStyle,
//     // this.messageController,
//   });

//   final String? hintText;
//   final void Function(String)? onChanged;
//   final FocusNode? focusNode;
//   final TextEditingController? controller;
//   final Icon? prefixIcon;
//   final bool isObscure;
//   final String? Function(String?)? validate;
//   final bool isSearch;
//   final bool isChat;
//   final String? labelText;
//   final bool? filled;
//   final TextStyle? labelStyle;
//   // final TextEditingController? messageController ;

//   @override
//   State<CustomTextField> createState() => _CustomTextFieldState();
// }

// class _CustomTextFieldState extends State<CustomTextField> {
//   late bool _obscureText;

//   @override
//   void initState() {
//     super.initState();
//     _obscureText = widget.isObscure;
//   }

//   @override
//   Widget build(BuildContext context) {
//     // bool isChat;
//     return

//     BlocBuilder(
//       builder: (context,State) {
//         return SizedBox(
//           height: widget.isChat ? 40.h : null,
//           // width: ,
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 6.w),
//             child: TextFormField(
//               cursorColor: Colors.grey.shade500,
//               // cursorHeight: 40.h,
//               validator: widget.validate,
//               obscureText: _obscureText,
//               controller: widget.controller,
//               onChanged: widget.onChanged,
//               focusNode: widget.focusNode,
//               decoration: InputDecoration(
//                   labelText: widget.labelText,
//                   labelStyle: widget.labelStyle,
//                   contentPadding:
//                       widget.isChat ? EdgeInsets.symmetric(horizontal: 12.w) : null,
//                   // focusedBorder: Colors.black,
//                   // focusColor: Colors.black,
//                   prefixIcon: widget.prefixIcon,
//                   suffixIcon: widget.isObscure
//                       ? IconButton(
//                           icon: Icon(
//                             _obscureText ? Icons.visibility_off : Icons.visibility,
//                             color: Colors.grey,
//                           ),
//                           onPressed: () {
//                               context.read<TextFieldBloc>().add(ToggleObscureEvent());
//                           },
//                         )
//                       : null,
//                   hintText: widget.hintText,
//                   hintStyle: const TextStyle(
//                     fontWeight: FontWeight.w300,
//                     fontSize: 14,
//                   ),
//                   filled: widget.filled,
//                   fillColor: widget.isChat ? Colors.white : grey.withOpacity(0.12),
//                   //   enabledBorder: OutlineInputBorder(
//                   //   borderSide: BorderSide(color: Colors.grey.shade600),
//                   //   borderRadius: BorderRadius.circular(10.r),
//                   // ),
//                   // focusedBorder: OutlineInputBorder(
//                   //   borderSide: BorderSide(color: Colors.grey.shade600, width: 1.5),
//                   //   borderRadius: BorderRadius.circular(10.r),
//                   // ),
//                   border: UnderlineInputBorder(),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: Colors.grey, width: 1),
//                   ),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: Colors.grey, width: 1),
//                   )
//                   // borderSide: BorderSide(
//                   //   color: Colors.grey.shade300,
//                   // )

//                   // borderSide: BorderSide.,
//                   // borderRadius: BorderRadius.circular(widget.isChat ? 20.r : 10.r),

//                   ),
//             ),
//           ),
//         );
//       }
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'text_field_bloc.dart'; // <- apna bloc import karna

// class CustomTextField extends StatelessWidget {
//   const CustomTextField({
//     super.key,
//     this.isChat = false,
//     this.hintText,
//     this.onChanged,
//     this.focusNode,
//     this.controller,
//     this.prefixIcon,
//     this.isObscure = false,
//     this.validate,
//     this.isSearch = false,
//     this.labelText,
//     this.filled,
//     this.labelStyle,
//   });

//   final String? hintText;
//   final void Function(String)? onChanged;
//   final FocusNode? focusNode;
//   final TextEditingController? controller;
//   final Icon? prefixIcon;
//   final bool isObscure;
//   final String? Function(String?)? validate;
//   final bool isSearch;
//   final bool isChat;
//   final String? labelText;
//   final bool? filled;
//   final TextStyle? labelStyle;

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<TextFieldBloc, TextFieldState>(
//       builder: (context, state) {
//         final obscure =
//             (state is ToggleObscureState) ? state.isObscure : isObscure;

//         return SizedBox(
//           height: isChat ? 40.h : null,
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 6.w),
//             child: TextFormField(
//               cursorColor: Colors.grey.shade500,
//               validator: validate,
//               obscureText: obscure,
//               controller: controller,
//               onChanged: onChanged,
//               focusNode: focusNode,
//               decoration: InputDecoration(
//                 labelText: labelText,
//                 labelStyle: labelStyle,
//                 contentPadding:
//                     isChat ? EdgeInsets.symmetric(horizontal: 12.w) : null,
//                 prefixIcon: prefixIcon,
//                 suffixIcon: isObscure
//                     ? IconButton(
//                         icon: Icon(
//                           obscure ? Icons.visibility_off : Icons.visibility,
//                           color: Colors.grey,
//                         ),
//                         onPressed: () {
//                           context
//                               .read<TextFieldBloc>()
//                               .add(ToggleObscureEvent());
//                         },
//                       )
//                     : null,
//                 hintText: hintText,
//                 hintStyle: const TextStyle(
//                   fontWeight: FontWeight.w300,
//                   fontSize: 14,
//                 ),
//                 filled: filled,
//                 fillColor: isChat ? Colors.white : grey.withOpacity(0.12),
//                 border: const UnderlineInputBorder(),
//                 enabledBorder: const UnderlineInputBorder(
//                   borderSide: BorderSide(color: Colors.grey, width: 1),
//                 ),
//                 focusedBorder: const UnderlineInputBorder(
//                   borderSide: BorderSide(color: Colors.grey, width: 1),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.isChat = false,
    this.hintText,
    this.onChanged,
    this.focusNode,
    this.controller,
    this.prefixIcon,
    this.isObscure = false,
    this.validate,
    this.isSearch = false,
    this.labelText,
    this.filled,
    this.labelStyle,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.fillColor
  });

  final String? hintText;
  final Color? fillColor;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final Icon? prefixIcon;
  final bool isObscure;
  final String? Function(String?)? validate;
  final bool isSearch;
  final bool isChat;
  final String? labelText;
  final bool? filled;
  final TextStyle? labelStyle;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isObscure;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.isChat ? 40.h : null,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: TextFormField(
          cursorColor: Colors.grey.shade500,
          validator: widget.validate,
          obscureText: _obscure,
          controller: widget.controller,
          onChanged: widget.onChanged,
          focusNode: widget.focusNode,
          decoration: InputDecoration(
            labelText: widget.labelText,
            labelStyle: widget.labelStyle,
            contentPadding:
                widget.isChat ? EdgeInsets.symmetric(horizontal: 12.w) : null,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.isObscure
                ? IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscure = !_obscure;
                      });
                    },
                  )
                : null,
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 14,
            ),
            filled: widget.filled,
            fillColor: widget.fillColor,
            // border: const UnderlineInputBorder(),
            border: widget.border,
            enabledBorder: widget.enabledBorder,
            // enabledBorder:
            // const UnderlineInputBorder(
            //   borderSide: BorderSide(color: Colors.grey, width: 1),
            // ),
            focusedBorder: widget.focusedBorder,
            // focusedBorder: const UnderlineInputBorder(
            //   borderSide: BorderSide(color: Colors.grey, width: 1),
            // ),
          ),
        ),
      ),
    );
  }
}
