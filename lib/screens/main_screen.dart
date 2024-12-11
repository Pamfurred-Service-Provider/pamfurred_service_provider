import 'package:flutter/material.dart';
import 'package:service_provider/Supabase/realtime_service.dart';
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

class MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  late RealtimeService realtimeService;
  int currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [];
  @override
  void initState() {
    super.initState();
    currentIndex = widget.selectedIndex; // Use the passed index
    // If there is an active session, start listening to appointments
    realtimeService = RealtimeService();
    realtimeService.listenToAppointments(); // Start listening to notifications
    print("LISTEN TO APPOINTMENTS LET'S GO!");

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
    WidgetsBinding.instance.addObserver(this); // Add lifecycle observer
  }

  @override
  void dispose() {
    _pageController.dispose();
    WidgetsBinding.instance
        .removeObserver(this); // Remove observer when disposing
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Restart listener on resume
      print("App resumed, restarting real-time listener...");
      realtimeService.listenToAppointments();
    }
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
