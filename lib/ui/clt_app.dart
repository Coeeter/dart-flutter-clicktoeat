import 'package:clicktoeat/ui/screens/auth/splash_screen.dart';
import 'package:clicktoeat/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class CltApp extends StatelessWidget {
  const CltApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClickToEat',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const SplashScreen(),
    );
  }
}
