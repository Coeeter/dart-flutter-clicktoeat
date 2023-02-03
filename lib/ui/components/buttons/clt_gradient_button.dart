import 'package:clicktoeat/ui/theme/colors.dart';
import 'package:flutter/material.dart';

class CltGradientButton extends StatelessWidget {
  final void Function() onClick;
  final String text;
  final bool isLoading;
  final Gradient gradient;

  const CltGradientButton({
    Key? key,
    required this.onClick,
    required this.text,
    this.gradient = const LinearGradient(
      colors: [lightOrange, mediumOrange],
    ),
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var disabledColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[700]
        : Colors.grey[300];

    return InkWell(
      onTap: isLoading ? null : onClick,
      borderRadius: const BorderRadius.all(
        Radius.circular(10),
      ),
      splashFactory: InkRipple.splashFactory,
      child: Ink(
        decoration: BoxDecoration(
          gradient: isLoading ? null : gradient,
          color: isLoading ? disabledColor : null,
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(),
                )
              : Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
