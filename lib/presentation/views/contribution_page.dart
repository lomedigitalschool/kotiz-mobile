// lib/presentation/widgets/contribution_modal.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/presentation/components/app_button.dart';
import 'package:kotiz_app/presentation/components/text_field.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ContributionPage extends StatefulWidget {
  const ContributionPage({super.key});

  @override
  State<ContributionPage> createState() => _ContributionPageState();
}

class _ContributionPageState extends State<ContributionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _anonyme = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            20, // remonte avec le clavier
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          // spacing: 15,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 100,
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(LucideIcons.x400, color: Colors.black),
                ),
                const Text(
                  'Nouvelle contribution',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Form(
              child: Column(
                spacing: 5,
                children: [
                  TextFieldComponent(labelTitle: "Montant"),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          "Numero de telephone",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(fontSize: 24, color: Colors.black45),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    children: [
                      Checkbox(
                        value: _anonyme,
                        onChanged: (bool? newValue) {
                          setState(() {
                            _anonyme = newValue ?? false;
                          });
                        },
                      ),
                      Text("Rester anonyme"),
                    ],
                  ),
                  IntlPhoneField(
                    controller: _phoneController,
                    initialCountryCode: "TG",
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    // decoration: ,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              text: "valiider",
              backgroundColor: ColorConstant.colorGreen,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pop(context, double.parse(_amountController.text));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
