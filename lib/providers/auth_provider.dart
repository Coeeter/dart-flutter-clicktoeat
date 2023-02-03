import 'dart:io';

import 'package:clicktoeat/data/exceptions/unauthenticated_exception.dart';
import 'package:clicktoeat/domain/user/user.dart';
import 'package:clicktoeat/domain/user/user_repo.dart';
import 'package:clicktoeat/providers/user_provider.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final UserRepo _userRepo;
  final UserProvider _userProvider;
  String? token;
  User? user;

  AuthProvider(this._userRepo, this._userProvider) {
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
      throw UnauthenticatedException();
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

  Future<void> updateAccountInfo({
    String? username,
    String? email,
    File? image,
  }) async {
    if (token == null) {
      throw UnauthenticatedException();
    }
    var updatedToken = await _userRepo.updateAccount(
      token: token!,
      username: username,
      email: email,
      image: image,
    );
    await _userRepo.saveToken(token: updatedToken);
    token = updatedToken;
    await getCurrentUser();
    _userProvider.users = _userProvider.users.map((e) {
      if (e.id == user!.id) {
        return user!;
      }
      return e;
    }).toList();
    _userProvider.notifyListeners();
  }

  Future<void> updatePassword(String password) async {
    if (token == null) {
      throw UnauthenticatedException();
    }
    var updatedToken = await _userRepo.updateAccount(
      token: token!,
      password: password,
    );
    await _userRepo.saveToken(token: updatedToken);
    token = updatedToken;
    notifyListeners();
  }

  Future<void> deleteAccount(String password) async {
    if (token == null) {
      throw UnauthenticatedException();
    }
    await _userRepo.deleteAccount(
      token: token!,
      password: password,
    );
    await logOut();
    _userProvider.users = _userProvider.users.where((e) {
      return e.id != user!.id;
    }).toList();
    _userProvider.notifyListeners();
  }
}
