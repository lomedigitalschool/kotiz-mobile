import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/logic/bottomNavCubit.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();

    int currentIndex = 0;
    if (location == "/") currentIndex = 0;
    if (location.startsWith("/explore")) currentIndex = 1;
    if (location.startsWith("/create")) currentIndex = 2;
    if (location.startsWith("/profil")) currentIndex = 3;

    return BottomNavigationBar(
      currentIndex: context.watch<BottomNavCubit>().state.currentIndex,
      onTap: (currentIndex) {
        context.read<BottomNavCubit>().setIndex(currentIndex);
        switch (currentIndex) {
          case 0:
            context.go("/");
            break;
          case 1:
            context.go("/explore");
            break;
          case 2:
            context.go("/create");
            break;
          case 3:
            context.go("/profil");
        }
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
    );
  }
}
