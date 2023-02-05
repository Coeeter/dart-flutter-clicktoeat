import 'package:clicktoeat/domain/common/image.dart';
import 'package:clicktoeat/domain/restaurant/restaurant.dart';
import 'dart:io';

import 'package:clicktoeat/domain/restaurant/restaurant_repo.dart';

class FakeRestaurantRepo implements RestaurantRepo {
  List<Restaurant> restaurants = [];

  FakeRestaurantRepo() {
    restaurants = List.generate(
      10,
      (index) => Restaurant(
        id: index.toString(),
        name: "name $index",
        description: "description $index",
        branches: [],
        image: Image(
          id: index,
          key: "key",
          url: 'https://picsum.photos/200/200',
        ),
      ),
    );
  }

  @override
  Future<String> createRestaurant({
    required String token,
    required String name,
    required String description,
    required File image,
  }) async {
    var restaurant = Restaurant(
      id: restaurants.length.toString(),
      name: name,
      description: description,
      branches: [],
      image: Image(
        id: restaurants.length,
        key: "key",
        url: 'https://picsum.photos/200/200',
      ),
    );
    restaurants.add(restaurant);
    return restaurant.id;
  }

  @override
  Future<void> deleteRestaurant({
    required String token,
    required String restaurantId,
  }) async {
    restaurants.removeWhere((element) => element.id == restaurantId);
  }

  @override
  Future<List<Restaurant>> getAllRestaurants() async {
    return restaurants;
  }

  @override
  Future<Restaurant> getRestaurantById({
    required String restaurantId,
  }) async {
    return restaurants.firstWhere((element) => element.id == restaurantId);
  }

  @override
  Future<Restaurant> updateRestaurant({
    required String token,
    required String restaurantId,
    String? name,
    String? description,
    File? image,
  }) async {
    var restaurant = restaurants.firstWhere(
      (element) => element.id == restaurantId,
    );
    restaurant = Restaurant(
      id: restaurantId,
      name: name ?? restaurant.name,
      description: description ?? restaurant.description,
      image: restaurant.image,
      branches: [],
    );
    restaurants = restaurants.map((e) {
      if (e.id == restaurantId) {
        return restaurant;
      }
      return e;
    }).toList();
    return restaurant;
  }
}
