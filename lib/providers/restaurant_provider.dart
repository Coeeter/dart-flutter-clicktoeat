import 'dart:io';

import 'package:clicktoeat/data/exceptions/default_exception.dart';
import 'package:clicktoeat/domain/favorites/favorite_repo.dart';
import 'package:clicktoeat/domain/restaurant/restaurant.dart';
import 'package:clicktoeat/domain/restaurant/restaurant_repo.dart';
import 'package:clicktoeat/domain/user/user.dart';
import 'package:flutter/material.dart';

class TransformedRestaurant {
  Restaurant restaurant;
  List<User> usersWhoFavRestaurant;

  TransformedRestaurant({
    required this.restaurant,
    required this.usersWhoFavRestaurant,
  });
}

class RestaurantProvider extends ChangeNotifier {
  final RestaurantRepo _restaurantRepo;
  final FavoriteRepo _favoriteRepo;
  final BuildContext _context;
  bool isLoading = false;
  List<TransformedRestaurant> restaurantList = [];

  RestaurantProvider(
    this._context,
    this._restaurantRepo,
    this._favoriteRepo,
  ) {
    getRestaurants();
  }

  Future<void> getRestaurants() async {
    isLoading = true;
    notifyListeners();
    try {
      var restaurants = await _restaurantRepo.getAllRestaurants()
        ..sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
      var transformedRestaurants = restaurants.map((e) async {
        var favorites = await _favoriteRepo.getFavsOfRestaurant(
          restaurantId: e.id,
        );
        return TransformedRestaurant(
          restaurant: e,
          usersWhoFavRestaurant: favorites,
        );
      }).toList();
      restaurantList = await Future.wait(transformedRestaurants);
      isLoading = false;
      notifyListeners();
    } on DefaultException catch (e) {
      ScaffoldMessenger.of(_context).showSnackBar(
        SnackBar(content: Text(e.error)),
      );
    }
  }

  Future<void> addRestaurantToFavorite(
    String token,
    String restaurantId,
    User currentUser,
  ) async {
    var oldRestaurantList = restaurantList;
    restaurantList = restaurantList.map((e) {
      if (e.restaurant.id != restaurantId) return e;
      e.usersWhoFavRestaurant = e.usersWhoFavRestaurant..add(currentUser);
      return e;
    }).toList();
    notifyListeners();
    try {
      await _favoriteRepo.addFavorite(
        token: token,
        restaurantId: restaurantId,
      );
    } on DefaultException catch (e) {
      restaurantList = oldRestaurantList;
      notifyListeners();
      ScaffoldMessenger.of(_context).showSnackBar(
        SnackBar(content: Text(e.error)),
      );
    }
  }

  Future<void> removeRestaurantFromFavorite(
    String token,
    String restaurantId,
    User currentUser,
  ) async {
    var oldRestaurantList = restaurantList;
    restaurantList = restaurantList.map((e) {
      if (e.restaurant.id != restaurantId) return e;
      e.usersWhoFavRestaurant = e.usersWhoFavRestaurant
          .where((element) => element.id != currentUser.id)
          .toList();
      return e;
    }).toList();
    notifyListeners();
    try {
      await _favoriteRepo.removeFavorite(
        token: token,
        restaurantId: restaurantId,
      );
    } on DefaultException catch (e) {
      restaurantList = oldRestaurantList;
      notifyListeners();
      ScaffoldMessenger.of(_context).showSnackBar(
        SnackBar(content: Text(e.error)),
      );
    }
  }

  Future<void> createRestaurant(
    String token,
    String name,
    String description,
    File image,
  ) async {
    try {
      String insertId = await _restaurantRepo.createRestaurant(
        name: name,
        description: description,
        image: image,
        token: token,
      );
      var restaurant = await _restaurantRepo.getRestaurantById(
        restaurantId: insertId,
      );
      restaurantList = restaurantList
        ..add(
          TransformedRestaurant(
            restaurant: restaurant,
            usersWhoFavRestaurant: [],
          ),
        )
        ..sort((a, b) {
          return a.restaurant.name.compareTo(b.restaurant.name);
        });
      notifyListeners();
    } on DefaultException catch (e) {
      ScaffoldMessenger.of(_context).showSnackBar(
        SnackBar(content: Text(e.error)),
      );
    }
  }

  Future<void> updateRestaurant(
    String token,
    String restaurantId,
    String name,
    String description,
    File image,
  ) async {
    try {
      var restaurant = await _restaurantRepo.updateRestaurant(
        restaurantId: restaurantId,
        name: name,
        description: description,
        image: image,
        token: token,
      );
      var favorites = await _favoriteRepo.getFavsOfRestaurant(
        restaurantId: restaurantId,
      );
      restaurantList = restaurantList
        ..add(
          TransformedRestaurant(
            restaurant: restaurant,
            usersWhoFavRestaurant: favorites,
          ),
        )
        ..sort((a, b) {
          return a.restaurant.name
              .toLowerCase()
              .compareTo(b.restaurant.name.toLowerCase());
        });
      notifyListeners();
    } on DefaultException catch (e) {
      ScaffoldMessenger.of(_context).showSnackBar(
        SnackBar(content: Text(e.error)),
      );
    }
  }

  Future<void> deleteRestaurant(String token, String restaurantId) async {
    try {
      await _restaurantRepo.deleteRestaurant(
        token: token,
        restaurantId: restaurantId,
      );
      restaurantList = restaurantList
          .where((element) => element.restaurant.id != restaurantId)
          .toList();
      notifyListeners();
    } on DefaultException catch (e) {
      ScaffoldMessenger.of(_context).showSnackBar(
        SnackBar(content: Text(e.error)),
      );
    }
  }
}