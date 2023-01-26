import 'dart:convert';

import 'package:clicktoeat/data/exceptions/default_exception.dart';
import 'package:clicktoeat/data/favorites/remote/remote_favorite_dao.dart';
import 'package:clicktoeat/data/utils/network_utils.dart';
import 'package:clicktoeat/domain/user/user.dart';
import 'package:clicktoeat/domain/restaurant/restaurant.dart';
import 'package:http/http.dart';

class RemoteFavoriteDaoImpl extends NetworkUtils implements RemoteFavoriteDao {
  RemoteFavoriteDaoImpl() : super(path: "/api/favorites");

  @override
  Future<String> addFavorite({
    required String token,
    required String restaurantId,
  }) async {
    var response = await post(
      createUrl(endpoint: "/$restaurantId"),
      headers: createAuthorizationHeader(token),
    );
    if (response.statusCode != 200) {
      throw DefaultException.fromJson(jsonDecode(response.body));
    }
    var body = jsonDecode(response.body);
    return body["message"];
  }

  @override
  Future<List<User>> getFavsOfRestaurant({required String restaurantId}) async {
    var response = await get(createUrl(endpoint: "/restaurants/$restaurantId"));
    if (response.statusCode != 200) {
      throw DefaultException.fromJson(jsonDecode(response.body));
    }
    List<Map<String, dynamic>> body = jsonDecode(response.body);
    return body.map((e) => User.fromJson(e)).toList();
  }

  @override
  Future<List<Restaurant>> getFavsOfUser({required String userId}) async {
    var response = await get(createUrl(endpoint: "/users/$userId"));
    if (response.statusCode != 200) {
      throw DefaultException.fromJson(jsonDecode(response.body));
    }
    List<Map<String, dynamic>> body = jsonDecode(response.body);
    return body.map((e) => Restaurant.fromJson(e)).toList();
  }

  @override
  Future<void> removeFavorite({
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
}
