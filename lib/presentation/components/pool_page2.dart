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
  DateTime? _selectedDate;

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale("fr", "FR"),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
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
            borderRadius: 12,
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

          Row(
            spacing: 5,
            children: [
              Text(
                " Date limite de la cagnotte",
                style: TextStyle(fontSize: 24, color: Colors.black45),
              ),

              Text("*", style: TextStyle(color: Colors.red, fontSize: 24)),
            ],
          ),

          // SizedBox(height: 2),
          GestureDetector(
            onTap: () {
              _selectDate(context);
            },
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedDate != null
                        ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                        : "Choisir une date  ",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  Icon(Icons.calendar_today, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
