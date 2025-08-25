import 'package:flutter/material.dart';

class TextFieldComponenet extends StatelessWidget {
  final String labelTitle;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool obscureText;
  final Widget? suffixIcon;

  TextFieldComponenet({
    super.key,
    required this.labelTitle,
    required this.controller,
    required this.onChanged,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelTitle, style: TextStyle(fontSize: 24, color: Colors.black45)),
        SizedBox(height: 15),

        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
