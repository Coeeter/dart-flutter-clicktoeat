import 'package:clicktoeat/data/exceptions/unauthenticated_exception.dart';
import 'package:clicktoeat/domain/common/image.dart';
import 'package:clicktoeat/domain/user/user.dart';
import 'dart:io';

import 'package:clicktoeat/domain/user/user_repo.dart';

class FakeUserRepo implements UserRepo {
  String? token = DateTime.now().millisecondsSinceEpoch.toString();
  List<User> users = [];

  FakeUserRepo() {
    users = List.generate(
      10,
      (index) => User(
        id: index.toString(),
        username: "username $index",
        email: "email$index@gmail.com",
        image: Image(
          id: index,
          key: "key",
          url: 'https://picsum.photos/200/200',
        ),
      ),
    );
  }

  @override
  Future<void> deleteAccount({
    required String token,
    required String password,
  }) async {
    if (token != this.token) {
      throw UnauthenticatedException();
    }
    users.removeLast();
  }

  @override
  Future<List<User>> getAllUsers() async {
    return users;
  }

  @override
  Future<String> getToken() async {
    if (token == null) {
      throw UnauthenticatedException();
    }
    return token!;
  }

  @override
  Future<User> getUserById({required String id}) async {
    return users.firstWhere((user) => user.id == id);
  }

  @override
  Future<User> getUserByToken({required String token}) async {
    if (token != this.token) {
      throw UnauthenticatedException();
    }
    return users.last;
  }

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    if (email != users.last.email) {
      throw UnauthenticatedException();
    }
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  @override
  Future<String> register({
    required String username,
    required String email,
    required String password,
    File? image,
  }) async {
    var user = User(
      id: users.length.toString(),
      username: username,
      email: email,
      image: Image(
        id: users.length,
        key: "key",
        url: 'https://picsum.photos/200/200',
      ),
    );
    users.add(user);
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  @override
  Future<void> removeToken() async {
    token = null;
  }

  @override
  Future<void> saveToken({required String token}) async {
    this.token = token;
  }

  @override
  Future<String> sendPasswordResetLinkToEmail({required String email}) async {
    if (users.any((user) => user.email == email)) {
      return "success";
    }
    throw Exception();
  }

  @override
  Future<String> updateAccount({
    required String token,
    String? username,
    String? email,
    String? password,
    File? image,
    bool? deleteImage,
  }) async {
    var updatedUser = User(
      id: users.last.id,
      username: username ?? users.last.username,
      email: email ?? users.last.email,
      image: users.last.image,
    );
    users.removeLast();
    users.add(updatedUser);
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
