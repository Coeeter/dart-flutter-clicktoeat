import 'package:clicktoeat/data/user/local/local_user_dao.dart';
import 'package:clicktoeat/data/user/remote/remote_user_dao.dart';
import 'package:clicktoeat/domain/user/user.dart';
import 'dart:io';

import 'package:clicktoeat/domain/user/user_repo.dart';

class UserRepoImpl implements UserRepo {
  final RemoteUserDao _remoteUserDao;
  final LocalUserDao _localUserDao;

  UserRepoImpl({
    required RemoteUserDao remoteUserDao,
    required LocalUserDao localUserDao,
  })  : _remoteUserDao = remoteUserDao,
        _localUserDao = localUserDao;

  @override
  Future<void> deleteAccount({
    required String token,
    required String password,
  }) {
    return _remoteUserDao.deleteAccount(
      token: token,
      password: password,
    );
  }

  @override
  Future<List<User>> getAllUsers() {
    return _remoteUserDao.getAllUsers();
  }

  @override
  Future<String> getToken() {
    return _localUserDao.getToken();
  }

  @override
  Future<User> getUserById({required String id}) {
    return _remoteUserDao.getUserById(id: id);
  }

  @override
  Future<User> getUserByToken({required String token}) {
    return _remoteUserDao.getUserByToken(token: token);
  }

  @override
  Future<String> login({required String email, required String password}) {
    return _remoteUserDao.login(email: email, password: password);
  }

  @override
  Future<String> register({
    required String username,
    required String email,
    required String password,
    File? image,
  }) {
    return _remoteUserDao.register(
      username: username,
      email: email,
      password: password,
      image: image
    );
  }

  @override
  Future<void> removeToken() {
    return _localUserDao.removeToken();
  }

  @override
  Future<void> saveToken({required String token}) {
    return _localUserDao.saveToken(token: token);
  }

  @override
  Future<String> sendPasswordResetLinkToEmail({required String email}) {
    return _remoteUserDao.sendPasswordResetLinkToEmail(email: email);
  }

  @override
  Future<String> updateAccount({
    required String token,
    String? username,
    String? email,
    String? password,
    File? image,
    bool? deleteImage,
  }) {
    return _remoteUserDao.updateAccount(
      token: token,
      username: username,
      email: email,
      password: password,
      image: image,
      deleteImage: deleteImage,
    );
  }
}
