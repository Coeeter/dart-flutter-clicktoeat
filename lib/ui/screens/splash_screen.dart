import 'package:clicktoeat/providers/auth_provider.dart';
import 'package:clicktoeat/ui/screens/auth_screen.dart';
import 'package:clicktoeat/ui/screens/home_screen.dart';
import 'package:clicktoeat/ui/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double top = 0;
  double width = 30;
  double height = 30;
  double borderRadius = 50;
  double opacity = 0;
  Duration duration = const Duration(milliseconds: 350);

  void animateItems(BuildContext context) async {
    setState(() {
      top = MediaQuery.of(context).size.height / 2;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      duration = const Duration(milliseconds: 750);
      width = MediaQuery.of(context).size.width;
      height = MediaQuery.of(context).size.height;
      borderRadius = 0;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      duration = const Duration(milliseconds: 250);
      opacity = 1;
    });
    await Future.delayed(const Duration(milliseconds: 2000));
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token == null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(seconds: 1),
          pageBuilder: (_, __, ___) => const AuthScreen(),
        ),
      );
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) => animateItems(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedPositioned(
            width: width,
            height: height,
            top: top - height / 2,
            right: MediaQuery.of(context).size.width / 2 - width / 2,
            duration: duration,
            curve: Curves.fastOutSlowIn,
            child: Hero(
              tag: "logo",
              child: AnimatedContainer(
                duration: duration,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      lightOrange,
                      mediumOrange,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(borderRadius),
                  ),
                ),
                clipBehavior: Clip.hardEdge,
                alignment: Alignment.center,
                child: AnimatedOpacity(
                  duration: duration,
                  opacity: opacity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/clicktoeat_icon.svg",
                        width: 175,
                        height: 175,
                      ),
                      const SizedBox(height: 20),
                      const DefaultTextStyle(
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 60,
                          fontFamily: 'FreeStyleScript',
                        ),
                        child: Text('ClickToEat'),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
