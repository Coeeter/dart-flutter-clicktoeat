import 'dart:io';

import 'package:clicktoeat/ui/screens/auth/auth_screen.dart';
import 'package:clicktoeat/ui/screens/search/search_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_provider.dart';

void main() {
  group('Auth Screen widget tests', () {
    testWidgets(
      'When submit empty fields, should show error',
      (tester) async {
        await tester.pumpFrames(
          FakeProvider(child: const AuthScreen()),
          const Duration(seconds: 1),
        );
        await tester.tap(find.byKey(const ValueKey("login-button")));
        await tester.pumpAndSettle();
        expect(find.text("Email required!"), findsOneWidget);
        expect(find.text("Password required!"), findsOneWidget);
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'When submit invalid email field, should show error',
      (tester) async {
        await tester.pumpFrames(
          FakeProvider(child: const AuthScreen()),
          const Duration(seconds: 1),
        );
        await tester.enterText(
          find.byKey(const ValueKey('login-email-input')),
          "fa;lkdjfa;ksdlfj",
        );
        await tester.enterText(
          find.byKey(const ValueKey('login-password-input')),
          "fa;lkdjfa;ksdlfj",
        );
        await tester.tap(find.byKey(const ValueKey("login-button")));
        await tester.pumpAndSettle();
        expect(find.text("Invalid email!"), findsOneWidget);
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'When submit valid fields, should save new token',
      (tester) async {
        var widget = FakeProvider(child: const AuthScreen());
        await tester.pumpFrames(widget, const Duration(seconds: 1));
        var oldToken = widget.userRepo.token;
        var lastPerson = widget.userRepo.users.last;
        var lastPersonEmail = lastPerson.email;
        await tester.enterText(
          find.byKey(const ValueKey('login-email-input')),
          lastPersonEmail,
        );
        await tester.enterText(
          find.byKey(const ValueKey('login-password-input')),
          "fa;lkdjfa;ksdlfj",
        );
        await tester.tap(find.byKey(const ValueKey("login-button")));
        expect(widget.userRepo.token != oldToken, true);
      },
    );
  });

  group('Search Screen Test', () {
    setUpAll(() => HttpOverrides.global = null);

    testWidgets(
      'When search, should only show cards containing the text',
      (widgetTester) async {
        await HttpOverrides.runZoned(
          () async {
            await widgetTester.pumpFrames(
              FakeProvider(child: const SearchScreen()),
              const Duration(seconds: 1),
            );
            await widgetTester.enterText(
              find.byKey(const ValueKey('search-input')),
              "9",
            );
            await widgetTester.pump(const Duration(seconds: 1));
            expect(find.byKey(const ValueKey('search-card')), findsNWidgets(2));
          },
        );
        await widgetTester.pumpAndSettle();
      },
    );

    testWidgets(
      'When search with invalid query, should show no cards at all',
      (widgetTester) async {
        await HttpOverrides.runZoned(
          () async {
            await widgetTester.pumpFrames(
              FakeProvider(child: const SearchScreen()),
              const Duration(seconds: 1),
            );
            await widgetTester.enterText(
              find.byKey(const ValueKey('search-input')),
              "fasdfadfadf",
            );
            await widgetTester.pump(const Duration(seconds: 1));
            expect(find.byKey(const ValueKey('search-card')), findsNothing);
            expect(find.text("No users found"), findsOneWidget);
            expect(find.text("No restaurants found"), findsOneWidget);
          },
        );
        await widgetTester.pumpAndSettle();
      },
    );
  });
}
