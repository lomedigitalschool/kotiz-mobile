import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/logic/bottom_nav_cubit.dart';
import 'package:kotiz_app/presentation/components/app_button.dart';
import 'package:kotiz_app/presentation/components/pool_page1.dart';
import 'package:kotiz_app/presentation/components/pool_page2.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  int currentStep = 0;

  final formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>()];

  List<Step> getSteps() => [
    Step(
      state: currentStep > 0 ? StepState.complete : StepState.indexed,
      title: Text(""),
      content: Form(key: formKeys[0], child: PoolPage1()),
      isActive: currentStep >= 0,
    ),
    Step(
      state: currentStep > 1 ? StepState.complete : StepState.indexed,
      title: Text(""),
      content: Form(key: formKeys[1], child: PoolPage2()),
      isActive: currentStep >= 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.read<BottomNavCubit>().setIndex(0);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: ColorConstant.colorWhite,
        appBar: AppBar(
          backgroundColor: ColorConstant.colorWhite,
          title: Text("Créer une cagnotte", style: TextStyle(fontSize: 24)),
          centerTitle: true,
          leading: IconButton(
            onPressed: () => context.read<BottomNavCubit>().setIndex(0),
            icon: Icon(
              LucideIcons.chevronLeft400,
              size: 50.0,
              color: ColorConstant.colorBlue,
            ),
          ),
        ),
        body: Stepper(
          steps: getSteps(),
          currentStep: currentStep,
          type: StepperType.horizontal,
          margin: EdgeInsetsGeometry.all(50),
          elevation: 0,
          stepIconMargin: EdgeInsets.all(0),
          onStepContinue: () {
            final form = formKeys[currentStep].currentState!;
            if (form.validate()) {
              setState(() {
                currentStep += 1;
              });
            }
          },
          onStepCancel: currentStep > 0
              ? () {
                  setState(() {
                    currentStep -= 1;
                  });
                }
              : null,
          controlsBuilder: (context, details) {
            return Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 15,
                children: [
                  SizedBox(height: 10),
                  AppButton(
                    onPressed: details.onStepContinue,
                    text: currentStep == 1 ? "Créer " : "Suivant",
                    backgroundColor: ColorConstant.colorGreen,
                  ),
                  currentStep == 1
                      ? AppButton(
                          onPressed: details.onStepCancel,
                          backgroundColor: Colors.grey,
                          text: "Retour",
                        )
                      : Text(""),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
