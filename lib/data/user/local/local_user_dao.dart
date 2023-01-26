abstract class LocalUserDao {
  Future<String> getToken();
  Future<void> saveToken({required String token});
  Future<void> removeToken();
}