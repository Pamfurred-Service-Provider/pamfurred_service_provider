import 'package:flutter/material.dart';
import 'package:service_provider/components/bottom_navbar.dart';
import 'package:service_provider/screens/home_screen.dart';
import 'package:service_provider/screens/profile.dart';
import 'package:service_provider/screens/notification_screen.dart';
import 'package:service_provider/screens/services.dart';

class MainScreen extends StatefulWidget {
  final int selectedIndex;
  const MainScreen({Key? key, this.selectedIndex = 0}) : super(key: key);

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [];
  @override
  void initState() {
    super.initState();
    currentIndex = widget.selectedIndex; // Use the passed index
    // Using WidgetsBinding to delay the jumpToPage until after the widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController
          .jumpToPage(currentIndex); // Now it's safe to call jumpToPage
    });
    _screens.addAll([
      HomeScreen(
        onCardTap: () {
          _pageController
              .jumpToPage(1); // Navigates to ServicesScreen (index 1)
        },
      ),
      const ServicesScreen(),
      const NotificationScreen(),
      const ProfileScreen(),
    ]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const AlwaysScrollableScrollPhysics(),
        onPageChanged: onPageChanged,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }
}
