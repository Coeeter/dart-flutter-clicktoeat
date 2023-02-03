import 'package:clicktoeat/domain/user/user.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final User user;

  const ProfileScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile of ${user.username}'),
      ),
      body: const Center(
        child: Text('Profile Screen'),
      ),
    );
  }
}
