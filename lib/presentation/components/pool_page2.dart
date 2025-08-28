import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kotiz_app/presentation/components/app_button.dart';
import 'package:kotiz_app/presentation/components/text_field.dart';

class PoolPage2 extends StatefulWidget {
  const PoolPage2({super.key});

  @override
  State<PoolPage2> createState() => _PoolPage2State();
}

class _PoolPage2State extends State<PoolPage2> {
  String? _typeSelected;

  List<String> _typeList = ["publique", "privée"];

  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        _images = images;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 15,
        children: [
          Row(
            spacing: 5,
            children: [
              Text(
                "Type",
                style: TextStyle(fontSize: 24, color: Colors.black45),
              ),

              Text("*", style: TextStyle(color: Colors.red, fontSize: 24)),
            ],
          ),

          DropdownButtonFormField<String>(
            value: _typeSelected,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            hint: Text(
              "Choisissez le type de cagnotte",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            items: _typeList.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _typeSelected = newValue;
              });
            },
          ),
          Row(
            spacing: 5,
            children: [
              Text(
                "Image(s) descriptif(s)",
                style: TextStyle(fontSize: 24, color: Colors.black45),
              ),

              Text("*", style: TextStyle(color: Colors.red, fontSize: 24)),
            ],
          ),

          AppButton(
            text: _images.isNotEmpty
                ? "${_images.length} image${_images.length > 1 ? "s" : ""} selectionnée${_images.length > 1 ? "s" : ""}"
                : "Choisir une ou plusieurs images",
            onPressed: _pickImages,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black26,
          ),

          if (_images.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 images par ligne
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_images[index].path),
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),

          TextFieldComponent(labelTitle: "Date limite", astherix: true),
        ],
      ),
    );
  }
}
