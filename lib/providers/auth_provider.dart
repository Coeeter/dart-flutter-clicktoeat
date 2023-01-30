import 'package:clicktoeat/data/exceptions/unauthenticated_exception.dart';
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
      } on UnauthenticatedException {
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

  Future<void> login(String email, String password) async {
    var resultToken = await _userRepo.login(
      email: email,
      password: password,
    );
    await _userRepo.saveToken(token: resultToken);
    token = resultToken;
    await getCurrentUser();
  }

  Future<void> register(String username, String email, String password) async {
    var resultToken = await _userRepo.register(
      username: username,
      email: email,
      password: password,
    );
    await _userRepo.saveToken(token: resultToken);
    token = resultToken;
    await getCurrentUser();
  }

  Future<void> logOut() async {
    token = null;
    user = null;
    await _userRepo.removeToken();
    notifyListeners();
  }
}
