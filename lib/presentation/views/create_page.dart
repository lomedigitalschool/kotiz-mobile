import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/data/models/pool.data.dart';
import 'package:kotiz_app/logic/bottom_nav_cubit.dart';
import 'package:kotiz_app/logic/pool_cubit.dart';
import 'package:kotiz_app/presentation/components/app_button.dart';
import 'package:kotiz_app/presentation/components/pool_page1.dart';
import 'package:kotiz_app/presentation/components/pool_page2.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:toastification/toastification.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  int currentStep = 0;

  final formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>()];
  PoolData poolData = PoolData();

  List<Step> getSteps() => [
    Step(
      state: currentStep > 0 ? StepState.complete : StepState.indexed,
      title: Text(""),
      content: Form(
        key: formKeys[0],
        child: PoolPage1(poolData: poolData),
      ),
      isActive: currentStep >= 0,
    ),
    Step(
      state: currentStep > 1 ? StepState.complete : StepState.indexed,
      title: Text(""),
      content: Form(
        key: formKeys[1],
        child: PoolPage2(poolData: poolData),
      ),
      isActive: currentStep >= 1,
    ),
  ];

  void _submit() async {
    // print(poolData.toJson());
    await context.read<PoolCubit>().create(poolData);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.read<BottomNavCubit>().setIndex(0);

        return false;
      },
      child: BlocListener<PoolCubit, PoolState>(
        listener: (context, state) {
          if (state is PoolError) {
            toastification.show(
              context: context,
              type: ToastificationType.error,
              title: const Text("Échec lors de la creation de la cagnotte"),
              description: Text(state.message),
              icon: const Icon(Icons.error, color: Colors.white),
              backgroundColor: Colors.red.shade200,
              autoCloseDuration: Duration(seconds: 3),
              animationDuration: Duration(milliseconds: 600),
            );
          }
          final String message = state is PoolCreated
              ? state.poolCreated["message"]
              : "";
          if (state is PoolCreated) {
            toastification.show(
              context: context,
              type: ToastificationType.success,
              title: Text(message),
              icon: const Icon(Icons.error, color: Colors.white),
              backgroundColor: Colors.green.shade200,
              autoCloseDuration: Duration(seconds: 3),
              animationDuration: Duration(milliseconds: 600),
            );
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
                if (currentStep == 1) {
                  _submit();
                } else {
                  setState(() => currentStep += 1);
                }
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
      ),
    );
  }
}
