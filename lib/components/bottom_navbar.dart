import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:service_provider/components/globals.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class CustomBottomNavBar extends StatelessWidget {
  final Function(int) onTap;
  final int currentIndex;

  const CustomBottomNavBar(
      {required this.onTap, required this.currentIndex, super.key});

  @override
  Widget build(BuildContext context) {
    return SalomonBottomBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        SalomonBottomBarItem(
          icon: const Icon(Icons.home, size: 30),
          title: const Text("Home", style: TextStyle(fontSize: regularText)),
          selectedColor: primaryColor,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.pets, size: 30),
          title:
              const Text("Services", style: TextStyle(fontSize: regularText)),
          selectedColor: primaryColor,
        ),
        SalomonBottomBarItem(
          icon: const Icon(CupertinoIcons.bell_fill, size: 30),
          title: const Text("Notifications",
              style: TextStyle(fontSize: regularText)),
          selectedColor: primaryColor,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.person, size: 30),
          title: const Text("Profile", style: TextStyle(fontSize: regularText)),
          selectedColor: primaryColor,
        ),
      ],
    );
  }
}
