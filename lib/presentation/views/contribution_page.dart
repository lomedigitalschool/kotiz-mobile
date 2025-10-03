// lib/presentation/widgets/contribution_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/logic/contribution_cubit.dart';
import 'package:kotiz_app/presentation/components/app_button.dart';
import 'package:kotiz_app/presentation/components/text_field.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:toastification/toastification.dart';

class ContributionPage extends StatefulWidget {
  final String poolId;
  const ContributionPage({super.key, required this.poolId});

  @override
  State<ContributionPage> createState() => _ContributionPageState();
}

class _ContributionPageState extends State<ContributionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();
  // final _phoneController = TextEditingController();
  bool _anonyme = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Padding(
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
              Column(
                spacing: 5,
                children: [
                  TextFieldComponent(
                    labelTitle: "Montant",
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Ce champ est obligatoire";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  TextFieldComponent(
                    labelTitle: "Message (facultatif)",
                    maxLines: 5,
                    controller: _messageController,
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
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.start,
                  //   children: [
                  //     Flexible(
                  //       child: Text(
                  //         "Numero de telephone",
                  //         overflow: TextOverflow.ellipsis,
                  //         maxLines: 1,
                  //         style: TextStyle(fontSize: 24, color: Colors.black45),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // IntlPhoneField(
                  //   controller: _phoneController,
                  //   initialCountryCode: "TG",
                  //   decoration: InputDecoration(
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //   ),
                  //   // decoration: ,
                  // ),
                ],
              ),
              const SizedBox(height: 20),
              BlocListener<ContributionCubit, ContributionState>(
                listener: (context, state) {
                  if (state is ContributionError) {
                    toastification.show(
                      context: context,
                      type: ToastificationType.error,
                      title: const Text('Echec '),
                      description: Text(state.message),
                      icon: const Icon(Icons.error, color: Colors.white),
                      backgroundColor: Colors.red.shade200,
                      autoCloseDuration: Duration(seconds: 3),
                      animationDuration: Duration(milliseconds: 600),
                    );
                  }
                  if (state is ContributionSuccess) {
                    toastification.show(
                      context: context,
                      type: ToastificationType.success,
                      title: const Text('Contribution ajouté'),
                      description: Text("Merci pour votre contribution"),
                      icon: const Icon(Icons.error, color: Colors.white),
                      backgroundColor: Colors.green.shade200,
                      autoCloseDuration: Duration(seconds: 3),
                      animationDuration: Duration(milliseconds: 600),
                    );
                    context.pop();
                  }
                },
                child: BlocBuilder<ContributionCubit, ContributionState>(
                  builder: (context, state) {
                    bool isLoading = false;

                    if (state is ContributionProgress) {
                      isLoading = true;
                    }

                    return AppButton(
                      widget: isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                      text: "Valider",
                      backgroundColor: isLoading == true
                          ? Colors.grey
                          : ColorConstant.colorGreen,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (isLoading == false) {
                            context.read<ContributionCubit>().contribute(
                              poolId: widget.poolId,
                              amount: int.parse(_amountController.text),
                              message: _messageController.text,
                              isAnonymous: _anonyme,
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
