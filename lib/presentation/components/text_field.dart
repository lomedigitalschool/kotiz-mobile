import 'package:flutter/material.dart';

class TextFieldComponent extends StatelessWidget {
  final String labelTitle;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final Widget? suffixIcon;
  final bool astherix;
  final bool isPhone;
  TextInputType keyboardType;

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
  });

  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 5,
          children: [
            Text(
              labelTitle,
              style: TextStyle(fontSize: 24, color: Colors.black45),
            ),

            astherix
                ? Text("*", style: TextStyle(color: Colors.red, fontSize: 24))
                : SizedBox(width: 1),
          ],
        ),
        SizedBox(height: 15),

        TextField(
          keyboardType: keyboardType,
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
