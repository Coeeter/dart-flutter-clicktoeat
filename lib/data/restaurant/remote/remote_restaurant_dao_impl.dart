import 'dart:convert';
import 'dart:io';

import 'package:clicktoeat/data/exceptions/default_exception.dart';
import 'package:clicktoeat/data/exceptions/field_exception.dart';
import 'package:clicktoeat/data/restaurant/remote/remote_restaurant_dao.dart';
import 'package:clicktoeat/data/utils/network_utils.dart';
import 'package:clicktoeat/domain/restaurant/restaurant.dart';
import 'package:http/http.dart';

class RemoteRestaurantDaoImpl extends NetworkUtils
    implements RemoteRestaurantDao {
  RemoteRestaurantDaoImpl() : super(path: "/api/restaurants");

  @override
  Future<String> createRestaurant({
    required String token,
    required String name,
    required String description,
    required File image,
  }) async {
    var request = MultipartRequest("POST", createUrl())
      ..headers["authorization"] = "Bearer $token"
      ..fields["name"] = name
      ..fields["description"] = description
      ..files.add(await MultipartFile.fromPath("brandImage", image.path));
    var response = await Response.fromStream(await request.send());
    if (response.statusCode == 400) {
      throw FieldException.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode != 200) {
      throw DefaultException.fromJson(jsonDecode(response.body));
    }
    var body = jsonDecode(response.body) as Map;
    return body["insertId"];
  }

  @override
  Future<void> deleteRestaurant({
    required String token,
    required String restaurantId,
  }) async {
    var response = await delete(
      createUrl(endpoint: "/$restaurantId"),
      headers: createAuthorizationHeader(token),
    );
    if (response.statusCode == 200) return;
    throw DefaultException.fromJson(jsonDecode(response.body));
  }

  @override
  Future<List<Restaurant>> getAllRestaurants() async {
    var response = await get(createUrl());
    if (response.statusCode != 200) {
      throw DefaultException(
        error: "Unable to get restaurants. Try again later",
      );
    }
    var body = jsonDecode(response.body) as List;
    return body.map((e) => Restaurant.fromJson(e)).toList();
  }

  @override
  Future<Restaurant> getRestaurantById({required String restaurantId}) async {
    var response = await get(createUrl(endpoint: "/$restaurantId"));
    if (response.statusCode != 200) {
      throw DefaultException.fromJson(jsonDecode(response.body));
    }
    var body = jsonDecode(response.body);
    return Restaurant.fromJson(body);
  }

  @override
  Future<Restaurant> updateRestaurant({
    required String token,
    required String restaurantId,
    String? name,
    String? description,
    File? image,
  }) async {
    var request = MultipartRequest("PUT", createUrl(endpoint: "/$restaurantId"))
      ..headers["authorization"] = "Bearer $token";
    var length = 0;
    if (name != null) {
      request.fields["name"] = name;
      length += 1;
    }
    if (description != null) {
      request.fields["description"] = description;
      length += 1;
    }
    if (image != null) {
      request.files.add(
        await MultipartFile.fromPath("brandImage", image.path),
      );
      length += 1;
    }
    if (length == 0) {
      throw DefaultException(
        error: "Must have at least one field to update!",
      );
    }
    var response = await Response.fromStream(await request.send());
    if (response.statusCode != 200) {
      throw DefaultException.fromJson(jsonDecode(response.body));
    }
    var body = jsonDecode(response.body);
    return Restaurant.fromJson(body);
  }
}
