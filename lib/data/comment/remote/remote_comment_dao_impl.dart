import 'dart:convert';

import 'package:clicktoeat/data/comment/remote/remote_comment_dao.dart';
import 'package:clicktoeat/data/exceptions/default_exception.dart';
import 'package:clicktoeat/data/exceptions/field_exception.dart';
import 'package:clicktoeat/data/utils/network_utils.dart';
import 'package:clicktoeat/domain/comment/comment.dart';
import 'package:http/http.dart';

class RemoteCommentDaoImpl extends NetworkUtils implements RemoteCommentDao {
  RemoteCommentDaoImpl() : super(path: "/api/comments");

  @override
  Future<String> createComment({
    required String token,
    required String restaurantId,
    required String review,
    required int rating,
  }) async {
    var response = await post(
      createUrl(endpoint: "/$restaurantId"),
      headers: createAuthorizationHeader(token),
      body: {
        "review": review,
        "rating": rating,
      },
    );
    var body = jsonDecode(response.body);
    if (response.statusCode == 400) {
      throw FieldException.fromJson(body);
    }
    if (response.statusCode != 200) {
      throw DefaultException.fromJson(body);
    }
    return body["insertId"];
  }

  @override
  Future<void> deleteComment({
    required String token,
    required String commentId,
  }) async {
    var response = await delete(
      createUrl(endpoint: "/$commentId"),
      headers: createAuthorizationHeader(token),
    );
    if (response.statusCode == 200) return;
    Map<String, dynamic> body = jsonDecode(response.body);
    throw DefaultException.fromJson(body);
  }

  @override
  Future<List<Comment>> getAllComments() async {
    var response = await get(createUrl());
    if (response.statusCode != 200) {
      throw DefaultException.fromJson(jsonDecode(response.body));
    }
    List<Map<String, dynamic>> body = jsonDecode(response.body);
    return body.map((e) => Comment.fromJson(e)).toList();
  }

  @override
  Future<Comment> getCommentById({required String id}) async {
    var response = await get(createUrl(endpoint: "/$id"));
    if (response.statusCode != 200) {
      throw DefaultException.fromJson(jsonDecode(response.body));
    }
    Map<String, dynamic> body = jsonDecode(response.body);
    return Comment.fromJson(body);
  }

  @override
  Future<List<Comment>> getCommentsByRestaurant({
    required String restaurantId,
  }) async {
    var response = await get(createUrl(endpoint: "?restaurant=$restaurantId"));
    if (response.statusCode != 200) {
      throw DefaultException.fromJson(jsonDecode(response.body));
    }
    List<Map<String, dynamic>> body = jsonDecode(response.body);
    return body.map((e) => Comment.fromJson(e)).toList();
  }

  @override
  Future<List<Comment>> getCommentsByUser({required String userId}) async {
    var response = await get(createUrl(endpoint: "?user=$userId"));
    if (response.statusCode != 200) {
      throw DefaultException.fromJson(jsonDecode(response.body));
    }
    List<Map<String, dynamic>> body = jsonDecode(response.body);
    return body.map((e) => Comment.fromJson(e)).toList();
  }

  @override
  Future<Comment> updateComment({
    required String token,
    required String commentId,
    String? review,
    int? rating,
  }) async {
    var requestBody = <String, dynamic>{};
    var length = 0;
    if (review != null) {
      requestBody["review"] = review;
      length += 1;
    }
    if (rating != null) {
      requestBody["rating"] = rating;
      length += 1;
    }
    if (length == 0) {
      throw DefaultException(
        error: "Must have at least one field to update!",
      );
    }
    var response = await put(
      createUrl(endpoint: "/$commentId"),
      headers: createAuthorizationHeader(token),
      body: requestBody,
    );
    if (response.statusCode == 400) {
      throw FieldException.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode != 200) {
      throw DefaultException.fromJson(jsonDecode(response.body));
    }
    return Comment.fromJson(jsonDecode(response.body));
  }
}
