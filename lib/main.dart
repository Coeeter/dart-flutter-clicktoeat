import 'package:clicktoeat/data/comment/comment_repo_impl.dart';
import 'package:clicktoeat/data/comment/remote/remote_comment_dao_impl.dart';
import 'package:clicktoeat/data/favorites/favorite_repo_impl.dart';
import 'package:clicktoeat/data/favorites/remote/remote_favorite_dao_impl.dart';
import 'package:clicktoeat/data/restaurant/remote/remote_restaurant_dao_impl.dart';
import 'package:clicktoeat/data/restaurant/restaurant_repo_impl.dart';
import 'package:clicktoeat/data/user/local/local_user_dao_impl.dart';
import 'package:clicktoeat/data/user/remote/remote_user_dao_impl.dart';
import 'package:clicktoeat/data/user/user_repo_impl.dart';
import 'package:clicktoeat/providers/auth_provider.dart';
import 'package:clicktoeat/providers/comment_provider.dart';
import 'package:clicktoeat/providers/restaurant_provider.dart';
import 'package:clicktoeat/ui/clt_app.dart';
import 'package:clicktoeat/ui/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: lightOrange,
    ),
  );

  var sharedPreferences = await SharedPreferences.getInstance();

  var userRepo = UserRepoImpl(
    remoteUserDao: RemoteUserDaoImpl(),
    localUserDao: LocalUserDaoImpl(
      preferences: sharedPreferences,
    ),
  );

  var restaurantRepo = RestaurantRepoImpl(
    restaurantDao: RemoteRestaurantDaoImpl(),
  );

  var commentRepo = CommentRepoImpl(
    remoteCommentDao: RemoteCommentDaoImpl(),
  );

  var favoriteRepo = FavoriteRepoImpl(
    remoteFavoriteDao: RemoteFavoriteDaoImpl(),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            context,
            userRepo,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => RestaurantProvider(
            context,
            restaurantRepo,
            favoriteRepo,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => CommentProvider(
            context,
            commentRepo,
          ),
        ),
      ],
      child: const CltApp(),
    ),
  );
}
