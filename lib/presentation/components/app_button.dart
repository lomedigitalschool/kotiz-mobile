import 'package:flutter/material.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;
  final Size size;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = ColorConstant.colorBlue,
    this.foregroundColor = ColorConstant.colorWhite,
    this.borderRadius = 5,
    this.fontSize = 16,
    this.fontWeight = FontWeight.bold,
    this.size = const Size(389, 55),
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        fixedSize: WidgetStatePropertyAll(size),
        backgroundColor: WidgetStatePropertyAll(backgroundColor),
        foregroundColor: WidgetStatePropertyAll(foregroundColor),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
      ),
    );
  }
}
