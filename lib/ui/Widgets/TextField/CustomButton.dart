import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:real_time_chat_application/core/constants/colors.dart';
import 'package:real_time_chat_application/core/constants/styles.dart';

class CustomButtonWidget extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final bool loading;
  final Color? backgroundColor;
  final Color? color;
  final double? fontSize;
  const CustomButtonWidget({
    super.key,
    this.onPressed,
    required this.text,
    this.loading = false,
    this.backgroundColor,
    this.color,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return SizedBox(
      width: orientation == Orientation.portrait ? 310.w : 750.w,
      height: orientation == Orientation.portrait ? 40.h : 25.h,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(13.r),
          ),
          // style: ElevatedButton.styleFrom(backgroundColor: backgroundColor),
          // onPressed: onPressed,
          child: loading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 3))
              : Center(
                  child: Text(text,
                      style: small.copyWith(color: color, fontSize: fontSize)),
                ),
        ),
      ),
    );
  }
}
