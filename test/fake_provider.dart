import 'package:clicktoeat/providers/auth_provider.dart';
import 'package:clicktoeat/providers/comment_provider.dart';
import 'package:clicktoeat/providers/restaurant_provider.dart';
import 'package:clicktoeat/providers/user_provider.dart';
import 'package:clicktoeat/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'fakes/fakes.dart';

class FakeProvider extends StatelessWidget {
  late final FakeRestaurantRepo restaurantRepo;
  late final FakeUserRepo userRepo;
  late final FakeBranchRepo branchRepo;
  late final FakeCommentRepo commentRepo;
  late final FakeFavoriteRepo favoriteRepo;
  late final UserProvider userProvider;
  late final AuthProvider authProvider;
  late final RestaurantProvider restaurantProvider;
  late final CommentProvider commentProvider;
  final Widget child;

  FakeProvider({
    Key? key,
    required this.child,
  }) : super(key: key) {
    restaurantRepo = FakeRestaurantRepo();
    userRepo = FakeUserRepo();
    branchRepo = FakeBranchRepo();
    commentRepo = FakeCommentRepo();
    favoriteRepo = FakeFavoriteRepo(userRepo, restaurantRepo);
  }

  @override
  Widget build(BuildContext context) {
    userProvider = UserProvider(userRepo);
    authProvider = AuthProvider(
      userRepo,
      userProvider,
    );
    restaurantProvider = RestaurantProvider(
      context,
      restaurantRepo,
      favoriteRepo,
      branchRepo,
    );
    commentProvider = CommentProvider(
      context,
      commentRepo,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => authProvider,
        ),
        ChangeNotifierProvider(
          create: (_) => userProvider,
        ),
        ChangeNotifierProvider(
          create: (context) => restaurantProvider,
        ),
        ChangeNotifierProvider(
          create: (context) => commentProvider,
        ),
      ],
      child: MaterialApp(
        title: 'ClickToEat',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        home: child,
      ),
    );
  }
}
