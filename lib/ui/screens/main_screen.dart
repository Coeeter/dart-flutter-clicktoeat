import 'package:animations/animations.dart';
import 'package:clicktoeat/ui/screens/profile/profile_screen.dart';
import 'package:clicktoeat/ui/screens/restaurant/home_screen.dart';
import 'package:clicktoeat/ui/screens/search/search_screen.dart';
import 'package:clicktoeat/ui/theme/colors.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var currentIndex = 0;
  var reverse = false;
  var screens = [
    const HomeScreen(),
    const SearchScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: mediumOrange,
        unselectedItemColor: mediumOrange.withAlpha(125),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            reverse = index < currentIndex;
            currentIndex = index;
          });
        },
      ),
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 750),
        reverse: reverse,
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
          return SharedAxisTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child,
          );
        },
        child: screens[currentIndex],
      ),
    );
  }
}
