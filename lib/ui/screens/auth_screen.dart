import 'package:clicktoeat/ui/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: lightOrange,
    ));

    return Scaffold(
      body: Column(
        children: [
          Hero(
            tag: "logo",
            child: Container(
                height: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      lightOrange,
                      mediumOrange,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(100),
                    bottomRight: Radius.circular(100),
                  ),
                ),
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
                )),
          )
        ],
      ),
    );
  }
}
