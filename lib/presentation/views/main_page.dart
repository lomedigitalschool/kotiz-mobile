import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/logic/bottomNavCubit.dart';
import 'package:kotiz_app/presentation/views/create_page.dart';
import 'package:kotiz_app/presentation/views/explore_page.dart';
import 'package:kotiz_app/presentation/views/home_page.dart';
import 'package:kotiz_app/presentation/views/profil_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.watch<BottomNavCubit>().state.currentIndex;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [HomePage(), ExplorePage(), CreatePage(), ProfilPage()],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: context.watch<BottomNavCubit>().state.currentIndex,
        onTap: (currentIndex) {
          context.read<BottomNavCubit>().setIndex(currentIndex);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: ColorConstant.colorWhite,
        selectedItemColor: ColorConstant.colorGreen,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        items: [
          BottomNavigationBarItem(
            activeIcon: Icon(
              LucideIcons.house600,
              color: ColorConstant.colorGreen,
            ),
            icon: Icon(LucideIcons.house200, color: Colors.black),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(
              LucideIcons.search600,
              color: ColorConstant.colorGreen,
            ),
            icon: Icon(LucideIcons.search, color: Colors.black),
            label: "Decouverte",
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(
              LucideIcons.squarePlus600,
              color: ColorConstant.colorGreen,
            ),
            icon: Icon(LucideIcons.squarePlus200, color: Colors.black),
            label: "Créer",
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(
              LucideIcons.userRound600,
              color: ColorConstant.colorGreen,
            ),
            icon: Icon(LucideIcons.userRound200, color: Colors.black),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}
