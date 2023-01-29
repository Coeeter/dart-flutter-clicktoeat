import 'package:clicktoeat/data/exceptions/unauthenticated_exception.dart';
import 'package:clicktoeat/data/user/local/local_user_dao.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalUserDaoImpl implements LocalUserDao {
  static const String _key = "token";
  final SharedPreferences _preferences;

  LocalUserDaoImpl({required SharedPreferences preferences})
      : _preferences = preferences;

  @override
  Future<String> getToken() async {
    var token = _preferences.getString(_key);
    if (token == null) throw UnauthenticatedException();
    return token;
  }

  @override
  Future<void> removeToken() async {
    await _preferences.remove(_key);
  }

  @override
  Future<void> saveToken({required String token}) async {
    await _preferences.setString(_key, token);
  }
}
