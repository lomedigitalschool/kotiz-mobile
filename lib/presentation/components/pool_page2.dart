import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kotiz_app/presentation/components/app_button.dart';

class PoolPage2 extends StatefulWidget {
  const PoolPage2({super.key});

  @override
  State<PoolPage2> createState() => _PoolPage2State();
}

class _PoolPage2State extends State<PoolPage2> {
  String? _typeSelected;
  DateTime? _selectedDate;

  final List<String> _typeList = ["publique", "privée"];

  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  Future<void> _pickImages() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image!.path.isNotEmpty) {
      setState(() {
        _image = image;
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
            text: _image != null
                ? " Une image selectionnée "
                : "Choisir une  image",
            onPressed: _pickImages,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black26,
            borderRadius: 12,
          ),
          if (_image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(_image!.path),
                fit: BoxFit.cover,
                height:
                    200, // tu peux définir une taille pour éviter qu'elle explose l'écran
                width: double.infinity,
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
