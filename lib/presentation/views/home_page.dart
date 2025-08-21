import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/presentation/components/app_button.dart';
import 'package:kotiz_app/presentation/components/cagnotte_tile.dart';
import 'package:kotiz_app/presentation/views/create_page.dart';
import 'package:kotiz_app/presentation/views/explore_page.dart';
import 'package:kotiz_app/presentation/views/profil_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> pages = const [
    HomePage(),
    ExplorePage(),
    CreatePage(),
    ProfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstant.colorWhite,
        centerTitle: true,
        title: Image.asset("assets/images/Logo-Text.png", width: 100),
        actions: [
          TextButton(
            onPressed: () => context.go("/login"),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30, top: 64),
            child: Text(
              "Récentes cagnottes",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 12),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16),
              child: ListView.builder(
                itemCount: 8,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: CagnotteTile(
                      image: "assets/images/Logo-Text.png",
                      title: "Fluffy's Vet Bills",
                      currency: r'$',
                      amount: "200",
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 189),
          Column(
            children: [
              Center(
                child: AppButton(text: "Créer un compte", onPressed: () {}),
              ),
              SizedBox(height: 12),
              AppButton(
                text: "Créer une cagnotte",
                onPressed: () {},
                backgroundColor: ColorConstant.colorGreen,
              ),
              SizedBox(height: 72),
            ],
          ),
        ],
      ),
    );
  }
}
