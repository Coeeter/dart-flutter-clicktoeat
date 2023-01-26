import 'package:clicktoeat/data/favorites/remote/remote_favorite_dao.dart';
import 'package:clicktoeat/domain/favorites/favorite_repo.dart';
import 'package:clicktoeat/domain/user/user.dart';
import 'package:clicktoeat/domain/restaurant/restaurant.dart';

class FavoriteRepoImpl implements FavoriteRepo {
  final RemoteFavoriteDao _dao;

  FavoriteRepoImpl({required RemoteFavoriteDao remoteFavoriteDao})
      : _dao = remoteFavoriteDao;

  @override
  Future<String> addFavorite({
    required String token,
    required String restaurantId,
  }) {
    return _dao.addFavorite(token: token, restaurantId: restaurantId);
  }

  @override
  Future<List<User>> getFavsOfRestaurant({required String restaurantId}) {
    return _dao.getFavsOfRestaurant(restaurantId: restaurantId);
  }

  @override
  Future<List<Restaurant>> getFavsOfUser({required String userId}) {
    return _dao.getFavsOfUser(userId: userId);
  }

  @override
  Future<void> removeFavorite({
    required String token,
    required String restaurantId,
  }) {
    return _dao.removeFavorite(token: token, restaurantId: restaurantId);
  }
}
