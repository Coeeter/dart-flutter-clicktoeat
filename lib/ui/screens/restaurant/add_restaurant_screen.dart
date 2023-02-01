import 'package:flutter/material.dart';

class AddRestaurantScreen extends StatefulWidget {
  final void Function() navigateBack;
  const AddRestaurantScreen({
    Key? key,
    required this.navigateBack,
  }) : super(key: key);

  @override
  State<AddRestaurantScreen> createState() => _AddRestaurantScreenState();
}

class _AddRestaurantScreenState extends State<AddRestaurantScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Restaurant"),
        leading: IconButton(
          onPressed: widget.navigateBack,
          splashRadius: 20,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
    );
  }
}
