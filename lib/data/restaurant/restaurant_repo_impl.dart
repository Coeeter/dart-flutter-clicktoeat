import 'package:clicktoeat/data/restaurant/remote/remote_restaurant_dao.dart';
import 'package:clicktoeat/domain/restaurant/restaurant.dart';
import 'dart:io';

import 'package:clicktoeat/domain/restaurant/restaurant_repo.dart';

class RestaurantRepoImpl implements RestaurantRepo {
  final RemoteRestaurantDao _dao;

  RestaurantRepoImpl({required RemoteRestaurantDao restaurantDao})
      : _dao = restaurantDao;

  @override
  Future<String> createRestaurant({
    required String token,
    required String name,
    required String description,
    required File image,
  }) {
    return _dao.createRestaurant(
      token: token,
      name: name,
      description: description,
      image: image,
    );
  }

  @override
  Future<void> deleteRestaurant({
    required String token,
    required String restaurantId,
  }) {
    return _dao.deleteRestaurant(
      token: token,
      restaurantId: restaurantId,
    );
  }

  @override
  Future<List<Restaurant>> getAllRestaurants() {
    return _dao.getAllRestaurants();
  }

  @override
  Future<Restaurant> getRestaurantById({required String restaurantId}) {
    return _dao.getRestaurantById(restaurantId: restaurantId);
  }

  @override
  Future<Restaurant> updateRestaurant({
    required String token,
    required String restaurantId,
    String? name,
    String? description,
    File? image,
  }) {
    return _dao.updateRestaurant(
      token: token,
      restaurantId: restaurantId,
      name: name,
      description: description,
      image: image,
    );
  }
}
