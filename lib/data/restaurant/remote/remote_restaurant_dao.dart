import 'dart:io';

import 'package:clicktoeat/domain/restaurant/restaurant.dart';

abstract class RemoteRestaurantDao {
  Future<List<Restaurant>> getAllRestaurants();
  Future<Restaurant> getRestaurantById({required String restaurantId});
  Future<String> createRestaurant({
    required String token,
    required String name,
    required String description,
    required File image,
  });
  Future<Restaurant> updateRestaurant({
    required String token,
    required String restaurantId,
    String? name,
    String? description,
    File? image,
  });
  Future<void> deleteRestaurant({
    required String token,
    required String restaurantId,
  });
}