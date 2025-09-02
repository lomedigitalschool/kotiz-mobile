import 'package:flutter/material.dart';

class TextFieldComponent extends StatelessWidget {
  final String labelTitle;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final Widget? suffixIcon;
  final bool astherix;
  final bool isPhone;
  final TextInputType keyboardType;
  final TextOverflow overflow;
  final bool softWrap;

  @override
  TextFieldComponent({
    super.key,
    required this.labelTitle,
    this.controller,
    this.onChanged,
    this.obscureText = false,
    this.suffixIcon,
    this.astherix = false,
    this.isPhone = false,
    this.keyboardType = TextInputType.text,
    this.overflow = TextOverflow.ellipsis,
    this.softWrap = true,
  });

  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 5,
          children: [
            Flexible(
              child: Text(
                labelTitle,
                overflow: overflow,
                maxLines: 1,
                style: TextStyle(fontSize: 24, color: Colors.black45),
              ),
            ),

            astherix
                ? Text("*", style: TextStyle(color: Colors.red, fontSize: 24))
                : SizedBox(width: 1),
          ],
        ),

        TextField(
          keyboardType: keyboardType,
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
