import 'package:flutter/material.dart';

class TextFieldComponent extends StatelessWidget {
  final String labelTitle;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final Widget? suffixIcon;
  final bool astherix;
  final bool isPhone;
  final TextInputType keyboardType;
  final TextOverflow overflow;
  final bool softWrap;
  final int maxLines;
  final String? hintText;

  const TextFieldComponent({
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
    this.validator,
    this.maxLines = 1,
    this.hintText,
  });

  @override
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

        TextFormField(
          validator: validator,
          maxLines: maxLines,
          keyboardType: keyboardType,
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.black54),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
