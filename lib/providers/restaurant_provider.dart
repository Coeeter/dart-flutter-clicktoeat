import 'dart:io';

import 'package:clicktoeat/data/exceptions/default_exception.dart';
import 'package:clicktoeat/domain/restaurant/restaurant.dart';
import 'package:clicktoeat/domain/restaurant/restaurant_repo.dart';
import 'package:flutter/material.dart';

class RestaurantProvider extends ChangeNotifier {
  final RestaurantRepo _restaurantRepo;
  final BuildContext _context;
  bool isLoading = false;
  List<Restaurant> restaurantList = [];

  RestaurantProvider(this._context, this._restaurantRepo) {
    getRestaurants();
  }

  Future<void> getRestaurants() async {
    isLoading = true;
    notifyListeners();
    try {
      restaurantList = await _restaurantRepo.getAllRestaurants();
      isLoading = false;
      notifyListeners();
    } on DefaultException catch (e) {
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
        ..add(restaurant)
        ..sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
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
      restaurantList = restaurantList
        ..add(restaurant)
        ..sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
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
          .where((element) => element.id != restaurantId)
          .toList();
      notifyListeners();
    } on DefaultException catch (e) {
      ScaffoldMessenger.of(_context).showSnackBar(
        SnackBar(content: Text(e.error)),
      );
    }
  }
}
