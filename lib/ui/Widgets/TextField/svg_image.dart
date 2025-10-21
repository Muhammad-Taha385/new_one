import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:real_time_chat_application/core/constants/strings.dart';

class SvgPics extends StatelessWidget {
  final String? image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final String? semanticsLabel;
  const SvgPics({
    this.image,
    this.height,
    this.width,
    this.fit,
    this.semanticsLabel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      image!,
      height: height,
      width: width,
      fit: fit!,
      semanticsLabel: semanticsLabel,
    );
  }
}
