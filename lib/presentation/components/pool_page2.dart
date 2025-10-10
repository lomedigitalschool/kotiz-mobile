import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kotiz_app/data/models/pool.data.dart';
import 'package:kotiz_app/presentation/components/app_button.dart';
import 'package:kotiz_app/presentation/components/text_field.dart';

class PoolPage2 extends StatefulWidget {
  final PoolData poolData;
  const PoolPage2({super.key, required this.poolData});

  @override
  State<PoolPage2> createState() => _PoolPage2State();
}

class _PoolPage2State extends State<PoolPage2> {
  String? _typeSelected;
  DateTime? _selectedDate;

  final List<Map<String, String>> _typeList = [
    {"value": "public", "label": "Publique"},
    {"value": "private", "label": "Privée"},
  ];

  final ImagePicker _picker = ImagePicker();
  File? _image;

  Future<void> _pickImages() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      final File imageFile = File(pickedImage.path);

      setState(() {
        _image = imageFile;
      });

      widget.poolData.image = _image;
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
      widget.poolData.deadline = picked;
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Ce champ est obligatoire";
              }
              return null;
            },
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
            items: _typeList.map((Map<String, String> item) {
              return DropdownMenuItem<String>(
                value: item["value"],
                child: Text(item["label"]!),
              );
            }).toList(),
            onChanged: (v) =>
                widget.poolData.type = v == "publique" ? "public" : "private",
          ),

          TextFieldComponent(
            labelTitle: "Limite de participants (optionnel)",
            keyboardType: TextInputType.number,
            onChanged: (v) {
              final parsed = int.tryParse(v);
              if (parsed != null) {
                widget.poolData.participantLimit = parsed;
              }
            },
          ),

          Row(
            spacing: 5,
            children: [
              Text(
                "Image descriptif",
                style: TextStyle(fontSize: 24, color: Colors.black45),
              ),
            ],
          ),

          AppButton(
            text: _image != null
                ? " Une image selectionnée "
                : "Choisir une  image",
            onPressed: _pickImages,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black26,
            borderRadius: 12,
          ),
          if (_image != null)
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_image!.path),
                      fit: BoxFit.cover,
                      height: 120,
                      width: double.infinity,
                    ),
                  ),

                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _image = null;
                          widget.poolData.image = null;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
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
