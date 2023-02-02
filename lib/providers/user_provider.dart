import 'package:clicktoeat/domain/user/user.dart';
import 'package:clicktoeat/domain/user/user_repo.dart';
import 'package:clicktoeat/providers/auth_provider.dart';
import 'package:flutter/cupertino.dart';

class UserProvider extends ChangeNotifier {
  List<User> users = [];
  final AuthProvider _authProvider;
  final UserRepo _userRepo;

  UserProvider(this._authProvider, this._userRepo) {
    (() async {
      await getUsers();
    })();
  }

  Future<void> getUsers() async {
    users = await _userRepo.getAllUsers();
    notifyListeners();
  }

  Future<User> getUserById(String id) async {
    var user = await _userRepo.getUserById(id: id);
    return user;
  }
}
