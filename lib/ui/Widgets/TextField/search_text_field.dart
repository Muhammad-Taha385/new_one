import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:real_time_chat_application/bloc/text_field_bloc/text_field_bloc.dart';
import 'package:real_time_chat_application/bloc/text_field_bloc/text_field_state.dart';
import 'package:real_time_chat_application/core/constants/colors.dart';
// import 'package:real_time_chat_application/core/constants/strings.dart';
class CustomSearchTextField extends StatelessWidget {
  const CustomSearchTextField({
    super.key,
    this.hintText,
    this.onChanged,
    this.focusNode,
    this.controller,
    this.prefixIcon,
    this.isObscure = false, // default to false
    this.validate,
    this.isSearch = false ,
  });

  final String? hintText;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final Icon? prefixIcon;
  final bool isObscure;
  final String? Function(String?)? validate;
  final bool isSearch ;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TextFieldBloc,TextFieldState>(
      builder: (context,state) {
            final obscure =
            (state is ToggleObscureState) ? state.isObscure : isObscure;
        return TextFormField(
          // contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
        
          validator: validate,
          obscureText: obscure,
          controller: controller,
          onChanged: onChanged,
          focusNode: focusNode,
          decoration: InputDecoration(
            // focusedBorder: Colors.black,
            // focusColor: Colors.black,
            prefixIcon: prefixIcon,
          suffixIcon: isSearch
            ? Padding(
          padding: EdgeInsets.zero,
          // child: Container(
          //   height: 50.h,
          //   width: 44.h,
          //   decoration: BoxDecoration(
          //     color: Colors.black, // or your custom dark color
          //     borderRadius: BorderRadius.circular(10.r),
          //   ),
            child: Icon(
              Icons.search,
              color: primary,
              size: 24.h,
              weight: 50,
            ),
          
        )
            : null             
            ,hintText: hintText,
            hintStyle: const TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 14,
            ),
            filled: true,
            fillColor: grey.withAlpha(30),
          //   enabledBorder: OutlineInputBorder(
          //   borderSide: BorderSide(color: Colors.grey.shade600),
          //   borderRadius: BorderRadius.circular(10.r),
          // ),
          // focusedBorder: OutlineInputBorder(
          //   borderSide: BorderSide(color: Colors.grey.shade600, width: 1.5),
          //   borderRadius: BorderRadius.circular(10.r),
          // ),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(50.r),
              
            ),
          ),
        );
      }
    );
  }
}
