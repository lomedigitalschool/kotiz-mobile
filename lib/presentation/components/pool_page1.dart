import 'package:flutter/material.dart';
import 'package:kotiz_app/data/models/pool.data.dart';
import 'package:kotiz_app/presentation/components/text_field.dart';

class PoolPage1 extends StatefulWidget {
  final PoolData poolData;

  const PoolPage1({super.key, required this.poolData});

  @override
  State<PoolPage1> createState() => _PoolPage1State();
}

class _PoolPage1State extends State<PoolPage1> {
  String? _selectedValue;
  final List<Map<String, String>> currencyList = [
    {"value": "XOF", "label": "XOF (Franc CFA)"},
    {"value": "EUR", "label": "EUR (Euro)"},
    {"value": "USD", "label": "USD (Dollar)"},
  ];

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
            onChanged: (v) => widget.poolData.title = v,
          ),
          TextFieldComponent(
            labelTitle: "Description",
            keyboardType: TextInputType.multiline,
            onChanged: (v) => widget.poolData.description = v,

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
            onChanged: (v) {
              final parsed = double.tryParse(v);
              if (parsed != null) {
                widget.poolData.goalAmount = parsed;
              }
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
                onChanged: (newValue) => widget.poolData.currency = newValue,

                hint: Text("Choisissez la devise"),
                items: currencyList.map((Map<String, String> item) {
                  return DropdownMenuItem<String>(
                    value: item["value"],
                    child: Text(item["label"]!),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
