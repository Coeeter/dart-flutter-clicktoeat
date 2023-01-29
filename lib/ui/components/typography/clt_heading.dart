import 'package:clicktoeat/ui/theme/colors.dart';
import 'package:flutter/material.dart';

class CltHeading extends StatelessWidget {
  final String text;
  final Gradient gradient;
  final TextStyle textStyle;

  const CltHeading({
    Key? key,
    required this.text,
    this.gradient = const LinearGradient(
      colors: [
        lightOrange,
        mediumOrange,
      ],
    ),
    this.textStyle = const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return gradient.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        );
      },
      child: Text(text, style: textStyle),
    );
  }
}
