import 'package:clicktoeat/domain/restaurant/restaurant.dart';
import 'package:clicktoeat/domain/user/user.dart';

abstract class RemoteFavoriteDao {
  Future<List<Restaurant>> getFavsOfUser({required String userId});
  Future<List<User>> getFavsOfRestaurant({required String restaurantId});
  Future<String> addFavorite({
    required String token,
    required String restaurantId,
  });
  Future<void> removeFavorite({
    required String token,
    required String restaurantId,
  });
}
