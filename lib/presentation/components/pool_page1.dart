import 'package:flutter/material.dart';
import 'package:kotiz_app/presentation/components/text_field.dart';

class PoolPage1 extends StatefulWidget {
  const PoolPage1({super.key});

  @override
  State<PoolPage1> createState() => _PoolPage1State();
}

class _PoolPage1State extends State<PoolPage1> {
  String? _selectedValue;
  final List<String> currencyList = ["EUR", "DOLLAR", "XOF"];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        spacing: 50,
        children: [
          TextFieldComponent(
            labelTitle: "Titre",
            astherix: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Ce champ est obligatoire";
              }
              return null;
            },
          ),
          TextFieldComponent(
            labelTitle: "Description",
            keyboardType: TextInputType.multiline,

            maxLines: 5,
          ),
          TextFieldComponent(
            labelTitle: "Montant",
            keyboardType: TextInputType.number,
            astherix: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Ce champ est obligatoire";
              }
              return null;
            },
          ),

          Column(
            spacing: 8,
            children: [
              Row(
                spacing: 5,
                children: [
                  Text(
                    "Devise",
                    style: TextStyle(fontSize: 24, color: Colors.black45),
                  ),

                  Text("*", style: TextStyle(color: Colors.red, fontSize: 24)),
                ],
              ),

              DropdownButtonFormField<String>(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuiller choisir une devise";
                  }
                  return null;
                },
                value: _selectedValue,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                hint: Text("Choisissez la devise"),
                items: currencyList.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedValue = newValue;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
