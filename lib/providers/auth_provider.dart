import 'package:clicktoeat/data/exceptions/default_exception.dart';
import 'package:clicktoeat/domain/user/user.dart';
import 'package:clicktoeat/domain/user/user_repo.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final UserRepo _userRepo;
  final BuildContext _context;
  String? token;
  User? user;

  AuthProvider(this._context, this._userRepo) {
    (() async {
      try {
        await getToken();
      } on DefaultException {
        return;
      }
      await getCurrentUser();
    })();
  }

  Future<void> getToken() async {
    token = await _userRepo.getToken();
    notifyListeners();
  }

  Future<void> getCurrentUser() async {
    if (token == null) {
      ScaffoldMessenger.of(_context).showSnackBar(
        const SnackBar(
          content: Text("Must be logged in to do this action!"),
        ),
      );
      return;
    }
    user = await _userRepo.getUserByToken(token: token!);
    notifyListeners();
  }

  void logOut() {
    token = null;
    user = null;
    notifyListeners();
  }
}
