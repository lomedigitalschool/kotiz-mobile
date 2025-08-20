import 'package:flutter/material.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/presentation/components/AppButton.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstant.colorWhite,
        centerTitle: true,
        title: Image.asset("assets/images/Logo-Text.png", width: 100),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              "Se connecter",
              style: TextStyle(
                color: ColorConstant.colorBlue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: ColorConstant.colorWhite,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 64),
            child: Text(
              "Recentes cagnottes",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 12),

          // ListView.builder(
          //   itemCount: 8,
          //   scrollDirection: Axis.horizontal,
          //   shrinkWrap: true,
          //   itemBuilder: () {
          //     Text("jfhjksdafjhsdjakh");
          //     Image.asset("assets/images/Logo.png");
          //    };
          // ),
          // SizedBox(height: 189),
          Column(
            children: [
              Center(
                child: AppButton(text: "Créer un compte", onPressed: () {}),
              ),
              SizedBox(height: 12),
              Center(
                child: AppButton(
                  text: "Créer une cagnotte",
                  onPressed: () {},
                  backgroundColor: ColorConstant.colorGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
