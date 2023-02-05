import 'package:clicktoeat/domain/favorites/favorite_repo.dart';
import 'package:clicktoeat/domain/user/user.dart';
import 'package:clicktoeat/domain/restaurant/restaurant.dart';

import 'fake_restaurant_repo.dart';
import 'fake_user_repo.dart';

class FakeFavoriteRepo implements FavoriteRepo {
  List<FakeFavorite> _favorites = [];
  final FakeUserRepo _userRepo;
  final FakeRestaurantRepo _restaurantRepo;

  FakeFavoriteRepo(this._userRepo, this._restaurantRepo) {
    _favorites = List.generate(
      10,
      (index) => FakeFavorite(
        id: index.toString(),
        userId: index.toString(),
        restaurantId: index.toString(),
      ),
    );
  }

  @override
  Future<String> addFavorite({
    required String token,
    required String restaurantId,
  }) async {
    var user = await _userRepo.getUserByToken(token: token);
    var favorite = FakeFavorite(
      id: _favorites.length.toString(),
      userId: user.id,
      restaurantId: restaurantId,
    );
    _favorites.add(favorite);
    return favorite.id;
  }

  @override
  Future<List<User>> getFavsOfRestaurant({required String restaurantId}) async {
    return await Future.wait(
      _favorites
          .where((element) => element.restaurantId == restaurantId)
          .map((e) => _userRepo.getUserById(id: e.userId))
          .toList(),
    );
  }

  @override
  Future<List<Restaurant>> getFavsOfUser({required String userId}) async {
    return _favorites
        .where((element) => element.userId == userId)
        .map(
          (e) => _restaurantRepo.restaurants.firstWhere(
            (element) => element.id == e.id,
          ),
        )
        .toList();
  }

  @override
  Future<void> removeFavorite({
    required String token,
    required String restaurantId,
  }) async {
    var user = await _userRepo.getUserByToken(token: token);
    _favorites.removeWhere(
      (element) => element.userId == user.id && element.restaurantId == restaurantId,
    );
  }
}

class FakeFavorite {
  String id;
  String userId;
  String restaurantId;

  FakeFavorite({
    required this.id,
    required this.userId,
    required this.restaurantId,
  });
}
