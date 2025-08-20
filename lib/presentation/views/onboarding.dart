import 'package:flutter/material.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/presentation/components/AppButton.dart';
import 'package:kotiz_app/presentation/components/pageBuilder.dart';
import 'package:kotiz_app/presentation/views/home_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  final pageController = PageController();

  bool isLastPage = false;

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 150,
        backgroundColor: ColorConstant.colorWhite,
        title: Image.asset('assets/images/onBoardingLogo.png'),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.only(bottom: 200),
        child: PageView(
          controller: pageController,
          onPageChanged: (index) {
            setState(() {
              isLastPage = index == 2 ? true : false;
            });
          },
          children: [
            Pagebuilder(
              title: "Lancez votre cotisation",
              subtitle:
                  'Créer votre cotisation en quelques  secondes pour un projet, un évènement ou une cause',
            ),
            Pagebuilder(
              title: " Contribuez en un clic",
              subtitle:
                  'Partagez le lien et vos proches peuvent participer sans créer de compte, en toute simplicité.',
            ),
            Pagebuilder(
              title: "Suivi instantané & retrait facile",
              subtitle:
                  'Suivez l’évolution de votre cotisation en temps réel et retirez vos fonds en toute  simplicité.',
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        color: ColorConstant.colorWhite,
        padding: EdgeInsets.symmetric(horizontal: 10),
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: SmoothPageIndicator(
                controller: pageController,
                count: 3,
                effect: SlideEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  spacing: 8,
                  dotColor: Colors.black26,
                  activeDotColor: ColorConstant.colorBlue,
                ),
                onDotClicked: (index) => pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 50),
                  curve: Curves.easeInOut,
                ),
              ),
            ),
            !isLastPage
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    spacing: 100,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool("showHome", true);
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                        },
                        child: Text(
                          "Passer",
                          style: TextStyle(
                            fontSize: 18,
                            color: ColorConstant.colorBlue,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 21.0),
                        child: AppButton(
                          text: !isLastPage ? "Suivant" : "Commencer",
                          onPressed: !isLastPage
                              ? () => pageController.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                )
                              : () async {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setBool("showHome", true);
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => HomePage(),
                                    ),
                                  );
                                },
                          size: Size(200, 55),
                        ),
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 21.0),
                    child: AppButton(
                      text: !isLastPage ? "Suivant" : "Commencer",
                      onPressed: !isLastPage
                          ? () => pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            )
                          : () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setBool("showHome", true);
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => HomePage(),
                                ),
                              );
                            },
                      size: Size(365, 55),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
