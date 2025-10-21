import 'package:flutter/material.dart';

class OnBoardingText extends StatelessWidget {
  final String? text;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final double? height;
  const OnBoardingText({
    this.text,
    this.color,
    this.fontSize,
    this.height,
    this.fontFamily,
    this.fontWeight,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text!,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontFamily: fontFamily,
        height: height,
      ),
    );
  }
}