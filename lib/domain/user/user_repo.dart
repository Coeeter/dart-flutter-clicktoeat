import 'dart:io';

import 'package:clicktoeat/domain/user/user.dart';

abstract class UserRepo {
  Future<String> getToken();
  Future<void> saveToken({required String token});
  Future<void> removeToken();
  Future<List<User>> getAllUsers();
  Future<User> getUserById({required String id});
  Future<User> getUserByToken({required String token});
  Future<String> sendPasswordResetLinkToEmail({required String email});
  Future<void> deleteAccount({
    required String token,
    required String password,
  });
  Future<String> updateAccount({
    required String token,
    String? username,
    String? email,
    String? password,
    File? image,
    bool? deleteImage,
  });
  Future<String> login({
    required String email,
    required String password,
  });
  Future<String> register({
    required String username,
    required String email,
    required String password,
    File? image,
  });
}
