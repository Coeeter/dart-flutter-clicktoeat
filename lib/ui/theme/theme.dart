import 'package:clicktoeat/ui/theme/colors.dart';
import 'package:flutter/material.dart';

var lightTheme = ThemeData.light().copyWith(
  colorScheme: const ColorScheme.light().copyWith(
    primary: mediumOrange,
  ),
  appBarTheme: const AppBarTheme(backgroundColor: mediumOrange, elevation: 0),
  scaffoldBackgroundColor: const Color(0xFFFFF0E5),
);

var darkTheme = ThemeData.dark().copyWith(
  colorScheme: const ColorScheme.dark().copyWith(
    primary: lightOrange,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF272727),
    elevation: 4,
  ),
  scaffoldBackgroundColor: const Color(0xFF121212),
);
