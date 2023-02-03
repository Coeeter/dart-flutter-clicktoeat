import 'package:animations/animations.dart';
import 'package:clicktoeat/domain/user/user.dart';
import 'package:clicktoeat/providers/auth_provider.dart';
import 'package:clicktoeat/ui/screens/profile/profile_screen.dart';
import 'package:clicktoeat/ui/screens/restaurant/home_screen.dart';
import 'package:clicktoeat/ui/screens/search/search_screen.dart';
import 'package:clicktoeat/ui/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var currentIndex = 0;
  var reverse = false;

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context);
    var currentUser = authProvider.user;
    var screens = [
      const HomeScreen(),
      const SearchScreen(),
      currentUser != null ? ProfileScreen(user: currentUser) : Container(),
    ];

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: currentUser?.image == null
                ? const Icon(Icons.person)
                : _buildUserProfilePicIcon(currentUser!),
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

  Widget _buildUserProfilePicIcon(User currentUser) {
    return Stack(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(5),
          child: const CircularProgressIndicator(),
        ),
        Container(
          width: 30,
          height: 30,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: currentIndex == 2
                ? Border.all(
                    color: mediumOrange,
                    width: 2,
                  )
                : null,
          ),
          child: ClipOval(
            child: Image.network(
              currentUser.image!.url,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}
