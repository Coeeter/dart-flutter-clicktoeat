import 'package:clicktoeat/providers/auth_provider.dart';
import 'package:clicktoeat/providers/user_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/fakes.dart';

void main() {
  group('User Provider', () {
    late UserProvider provider;
    late FakeUserRepo fakeUserRepo;
    setUpAll(() {
      fakeUserRepo = FakeUserRepo();
      provider = UserProvider(fakeUserRepo);
    });

    test('should return a list of users', () async {
      await provider.getUsers();
      expect(provider.users, isNotEmpty);
      expect(provider.users.length, fakeUserRepo.users.length);
    });

    test("should return one user if id is valid", () async {
      var user = await provider.getUserById("1");
      expect(user, isNotNull);
      expect(user.id, "1");
    });
  });

  group('Auth Provider', () {
    late AuthProvider authProvider;
    late UserProvider userProvider;
    late FakeUserRepo fakeUserRepo;
    setUp(() {
      fakeUserRepo = FakeUserRepo();
      userProvider = UserProvider(fakeUserRepo);
      authProvider = AuthProvider(fakeUserRepo, userProvider);
    });

    test('should return a token', () async {
      await authProvider.getToken();
      expect(authProvider.token, isNotNull);
      expect(authProvider.token == fakeUserRepo.token, isTrue);
    });

    test('should return a user', () async {
      await authProvider.getCurrentUser();
      expect(authProvider.user, isNotNull);
      expect(authProvider.user!.id, fakeUserRepo.users.last.id);
    });

    test(
      'When login, with valid credentials, should update token',
      () async {
        var oldToken = authProvider.token;
        var lastUser = fakeUserRepo.users.last;
        await authProvider.login(lastUser.email, "fasdfasdfasdf");
        expect(authProvider.token, isNotNull);
        expect(authProvider.token, isNot(oldToken));
      },
    );

    test(
      'When create account, should update token and users',
      () async {
        var oldToken = authProvider.token;
        await authProvider.register("test", "test@test.com", "fasdfasdfasdf");
        expect(authProvider.token, isNotNull);
        expect(authProvider.token, isNot(oldToken));
        expect(authProvider.user, isNotNull);
        expect(authProvider.user?.email == "test@test.com", isTrue);
        expect(userProvider.users.length, fakeUserRepo.users.length);
        expect(userProvider.users.last.email == "test@test.com", isTrue);
      },
    );

    test(
      'When logout, should update token',
      () async {
        var oldToken = authProvider.token;
        await authProvider.logOut();
        expect(authProvider.token, isNull);
        expect(authProvider.token, isNot(oldToken));
      },
    );

    test('When Delete account, should remove user', () async {
      var oldUserListSize = userProvider.users.length;
      var oldToken = authProvider.token;
      await authProvider.deleteAccount(";lfkajsd;lfkajs;dlkjfa");
      expect(authProvider.token, isNull);
      expect(authProvider.token, isNot(oldToken));
      expect(authProvider.user, isNull);
      expect(userProvider.users.length, oldUserListSize - 1);
    });

    test('When update account, should update user', () async {
      var oldToken = authProvider.token;
      var oldUser = authProvider.user;
      await authProvider.updateAccountInfo(
        username: "test",
        email: "test@test.com",
      );
      expect(authProvider.token, isNotNull);
      expect(authProvider.token, isNot(oldToken));
      expect(authProvider.user, isNotNull);
      expect(authProvider.user, isNot(oldUser));
      expect(authProvider.user?.email, "test@test.com");
      expect(authProvider.user?.username, "test");
      expect(fakeUserRepo.users.last.username, "test");
      expect(fakeUserRepo.users.last.email, "test@test.com");
    });
  });
}
