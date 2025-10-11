import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/logic/bottom_nav_cubit.dart';
import 'package:kotiz_app/presentation/views/create_page.dart';
import 'package:kotiz_app/presentation/views/dashboard_page.dart';
import 'package:kotiz_app/presentation/views/home_page.dart';
import 'package:kotiz_app/presentation/views/profil_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.watch<BottomNavCubit>().state.currentIndex;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [HomePage(), DashboardPage(), CreatePage(), ProfilPage()],
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
            activeIcon: Icon(Icons.house, color: ColorConstant.colorGreen),
            icon: Icon(Icons.house_outlined, color: Colors.black),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.dashboard, color: ColorConstant.colorGreen),
            icon: Icon(Icons.dashboard_outlined, color: Colors.black),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.add_box, color: ColorConstant.colorGreen),
            icon: Icon(Icons.add_box_outlined, color: Colors.black),
            label: "Créer",
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.person, color: ColorConstant.colorGreen),
            icon: Icon(Icons.person_outline, color: Colors.black),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}
